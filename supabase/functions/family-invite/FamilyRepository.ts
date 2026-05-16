import { getSupabaseAdmin } from '../_shared/supabaseClient.ts';
import { NotFoundError, ValidationError } from '../_shared/errorHandler.ts';

export interface Family {
  id: string;
  name: string;
  ownerId: string;
  inviteCode: string;
  maxMembers: number;
  createdAt: string;
}

export interface FamilyMember {
  id: string;
  familyId: string;
  userId: string;
  role: 'owner' | 'member';
  joinedAt: string;
  profile?: {
    name: string;
    avatarUrl?: string;
  };
}

export interface CreateFamilyDTO {
  name: string;
  ownerId: string;
}

export class FamilyRepository {
  static async create(data: CreateFamilyDTO): Promise<Family> {
    console.log('Creating family:', data.name);
    const supabase = getSupabaseAdmin();

    const { data: family, error: fError } = await supabase
      .from('families')
      .insert({ name: data.name, owner_id: data.ownerId })
      .select()
      .single();

    if (fError || !family) throw new Error(`Failed to create family: ${fError?.message}`);

    const { error: mError } = await supabase
      .from('family_members')
      .insert({
        family_id: family.id,
        user_id: data.ownerId,
        role: 'owner'
      });

    if (mError) throw new Error(`Failed to add owner to members: ${mError.message}`);

    const { error: pError } = await supabase
      .from('pantries')
      .insert({ family_id: family.id });

    if (pError) console.error('Warning: Failed to create family pantry:', pError.message);

    return this.mapToFamilyEntity(family);
  }

  static async findByInviteCode(inviteCode: string): Promise<Family> {
    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase
      .from('families')
      .select('*')
      .eq('invite_code', inviteCode)
      .single();

    if (error || !data) throw new NotFoundError('Nieprawidłowy kod zaproszenia');
    return this.mapToFamilyEntity(data);
  }

  static async findById(familyId: string): Promise<Family> {
    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase
      .from('families')
      .select('*')
      .eq('id', familyId)
      .single();

    if (error || !data) throw new NotFoundError('Nie znaleziono rodziny.');
    return this.mapToFamilyEntity(data);
  }

  static async addMember(familyId: string, userId: string): Promise<FamilyMember> {
    console.log('Adding member to family:', familyId);
    const supabase = getSupabaseAdmin();

    const { data: existingMember } = await supabase
      .from('family_members')
      .select('id')
      .eq('family_id', familyId)
      .eq('user_id', userId)
      .maybeSingle();

    if (existingMember) throw new ValidationError('Już jesteś członkiem tej rodziny');

    const family = await this.findById(familyId);
    const { count, error: cError } = await supabase
      .from('family_members')
      .select('*', { count: 'exact', head: true })
      .eq('family_id', familyId);

    if (cError) throw new Error(`Failed to check member count: ${cError.message}`);
    if ((count || 0) >= family.maxMembers) throw new ValidationError('Rodzina osiągnęła limit 6 osób');

    const { data: member, error: mError } = await supabase
      .from('family_members')
      .insert({
        family_id: familyId,
        user_id: userId,
        role: 'member'
      })
      .select()
      .single();

    if (mError) throw new Error(`Failed to add member: ${mError.message}`);
    return this.mapToMemberEntity(member);
  }

  static async removeMember(familyId: string, userId: string): Promise<void> {
    console.log('Removing member:', userId);
    const supabase = getSupabaseAdmin();

    const { data: member, error: mError } = await supabase
      .from('family_members')
      .select('role')
      .eq('family_id', familyId)
      .eq('user_id', userId)
      .single();

    if (mError || !member) throw new NotFoundError('Nie znaleziono członka rodziny.');
    if (member.role === 'owner') throw new ValidationError('Właściciel nie może opuścić rodziny. Najpierw usuń rodzinę.');

    const { error: dError } = await supabase
      .from('family_members')
      .delete()
      .eq('family_id', familyId)
      .eq('user_id', userId);

    if (dError) throw new Error(`Failed to remove member: ${dError.message}`);
  }

  static async getMembers(familyId: string): Promise<FamilyMember[]> {
    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase
      .from('family_members')
      .select(`
        id, family_id, user_id, role, joined_at,
        profiles:user_id (name, avatar_url)
      `)
      .eq('family_id', familyId)
      .order('role', { ascending: false })
      .order('joined_at', { ascending: true });

    if (error) throw new Error(`Failed to get members: ${error.message}`);
    
    return (data || []).map((row: any) => ({
      id: row.id,
      familyId: row.family_id,
      userId: row.user_id,
      role: row.role,
      joinedAt: row.joined_at,
      profile: row.profiles ? {
        name: row.profiles.name,
        avatarUrl: row.profiles.avatar_url
      } : undefined
    }));
  }

  static async delete(familyId: string, ownerId: string): Promise<void> {
    console.log('Deleting family:', familyId);
    const supabase = getSupabaseAdmin();

    const { data: family, error: fError } = await supabase
      .from('families')
      .select('owner_id')
      .eq('id', familyId)
      .single();

    if (fError || !family) throw new NotFoundError('Nie znaleziono rodziny.');
    if (family.owner_id !== ownerId) throw new ValidationError('Tylko właściciel może usunąć rodzinę.');

    const { error: dError } = await supabase
      .from('families')
      .delete()
      .eq('id', familyId);

    if (dError) throw new Error(`Failed to delete family: ${dError.message}`);
  }

  static async getUserFamily(userId: string): Promise<Family | null> {
    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase
      .from('family_members')
      .select('families (*)')
      .eq('user_id', userId)
      .maybeSingle();

    if (error || !data) return null;
    return this.mapToFamilyEntity(data.families);
  }

  private static mapToFamilyEntity(row: any): Family {
    return {
      id: row.id,
      name: row.name,
      ownerId: row.owner_id,
      inviteCode: row.invite_code,
      maxMembers: row.max_members,
      createdAt: row.created_at
    };
  }

  private static mapToMemberEntity(row: any): FamilyMember {
    return {
      id: row.id,
      familyId: row.family_id,
      userId: row.user_id,
      role: row.role,
      joinedAt: row.joined_at
    };
  }
}
