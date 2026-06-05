import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { handleError, ValidationError } from '../_shared/errorHandler.ts';
import { getUserId } from '../_shared/supabaseClient.ts';
import { SubscriptionGuard } from '../_shared/SubscriptionGuard.ts';
import { MacrosRepository } from './MacrosRepository.ts';
import { ProfileRepository } from './ProfileRepository.ts';
import { MacrosCalculator } from './MacrosCalculator.ts';
import type { DailyMacros } from './MacrosRepository.ts';
import type { MacroTargets } from './ProfileRepository.ts';
import {
  DailyMacrosSchema,
  WeeklyMacrosSchema
} from '../_shared/validators.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }
  try {
    const userId = await getUserId(req.headers.get('Authorization') || '');
    await SubscriptionGuard.checkAccess(userId);
    const { action, ...data } = await req.json();
    let res;
    switch (action) {
      case 'daily': {
        const { date } = DailyMacrosSchema.parse({ ...data, userId });
        const [m, t] = await Promise.all([
          MacrosRepository.getDailyTotals(userId, date),
          ProfileRepository.getTargets(userId)
        ]) as [DailyMacros, MacroTargets];
        res = MacrosCalculator.calculateDailyProgress(date, m, t);
        break;
      }
      case 'meals': {
        const { date } = DailyMacrosSchema.parse({ ...data, userId });
        res = await MacrosRepository.getMealsForDay(userId, date);
        break;
      }
      case 'log_meal': {
        res = await MacrosRepository.logMeal({ userId, ...data });
        break;
      }
      case 'delete_meal': {
        await MacrosRepository.deleteMeal(data.mealId as string, userId);
        res = { deleted: true };
        break;
      }
      case 'weekly': {
        const { startDate, endDate } = WeeklyMacrosSchema.parse(data);
        const [w, t] = await Promise.all([
          MacrosRepository.getWeeklyTotals(userId, startDate, endDate),
          ProfileRepository.getTargets(userId)
        ]) as [{ date: string; macros: DailyMacros }[], MacroTargets];
        res = MacrosCalculator.calculateWeeklyProgress(
          startDate, endDate, w, t
        );
        break;
      }
      case 'profile': {
        res = await ProfileRepository.getById(userId);
        break;
      }
      case 'update_profile': {
        res = await ProfileRepository.update(userId, data);
        break;
      }
      default:
        throw new ValidationError('Nieznana akcja');
    }
    return new Response(
      JSON.stringify({ success: true, data: res }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (e) { return handleError(e); }
});
