import { createClient, SupabaseClient, User } from 'https://esm.sh/@supabase/supabase-js@2';
import { NotFoundError } from './errorHandler.ts';

const supabaseUrl = Deno.env.get('SUPABASE_URL');
const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
const anonKey = Deno.env.get('SUPABASE_ANON_KEY');

if (!supabaseUrl) throw new Error('Brak SUPABASE_URL');
if (!serviceKey) throw new Error('Brak SUPABASE_SERVICE_ROLE_KEY');
if (!anonKey) throw new Error('Brak SUPABASE_ANON_KEY');

const SUPABASE_URL = supabaseUrl;
const SUPABASE_SERVICE_ROLE_KEY = serviceKey;
const SUPABASE_ANON_KEY = anonKey;

// Singleton instances
let supabaseAdminInstance: SupabaseClient | null = null;
let supabaseAuthInstance: SupabaseClient | null = null;

export const getSupabaseAdmin = (): SupabaseClient => {
  if (!supabaseAdminInstance) {
    supabaseAdminInstance = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    });
  }
  return supabaseAdminInstance;
};

export const getSupabaseAuth = (): SupabaseClient => {
  if (!supabaseAuthInstance) {
    supabaseAuthInstance = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    });
  }
  return supabaseAuthInstance;
};

export const getUser = async (authHeader: string): Promise<User> => {
  if (!authHeader) {
    throw new NotFoundError('Unauthorized');
  }

  const token = authHeader.replace('Bearer ', '').trim();
  if (!token) {
    throw new NotFoundError('Unauthorized');
  }

  const supabase = getSupabaseAuth();
  const { data: { user }, error } = await supabase.auth.getUser(token);

  if (error || !user) {
    throw new NotFoundError('Unauthorized');
  }

  return user;
};

export const getUserId = async (authHeader: string): Promise<string> => {
  const user = await getUser(authHeader);
  return user.id;
};
