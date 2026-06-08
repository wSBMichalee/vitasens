-- Tabela water_logs
CREATE TABLE public.water_logs (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    amount_ml integer NOT NULL,
    logged_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- RLS dla water_logs
ALTER TABLE public.water_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own water logs"
    ON public.water_logs FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own water logs"
    ON public.water_logs FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own water logs"
    ON public.water_logs FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own water logs"
    ON public.water_logs FOR DELETE
    USING (auth.uid() = user_id);

-- Dodanie daily_water_target do public.profiles
ALTER TABLE public.profiles ADD COLUMN daily_water_target integer;
