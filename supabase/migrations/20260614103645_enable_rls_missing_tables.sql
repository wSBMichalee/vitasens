-- daily_usage: user może czytać tylko swoje rekordy, brak innego dostępu z klienta
ALTER TABLE public.daily_usage ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own usage"
  ON public.daily_usage
  FOR SELECT
  USING (auth.uid() = user_id);

-- food_detection_cache: globalny cache, dostęp tylko przez service_role (edge functions)
ALTER TABLE public.food_detection_cache ENABLE ROW LEVEL SECURITY;

-- recipe_cache: globalny cache, dostęp tylko przez service_role (edge functions)
ALTER TABLE public.recipe_cache ENABLE ROW LEVEL SECURITY;
