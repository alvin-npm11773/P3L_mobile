-- Create couriers table
CREATE TABLE IF NOT EXISTS couriers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  phone TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create deliveries table
CREATE TABLE IF NOT EXISTS deliveries (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id TEXT NOT NULL,
  courier_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  recipient_name TEXT NOT NULL,
  address TEXT NOT NULL,
  phone TEXT NOT NULL,
  status TEXT DEFAULT 'Menunggu' CHECK (status IN ('Menunggu', 'Dalam Perjalanan', 'Selesai')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE couriers ENABLE ROW LEVEL SECURITY;
ALTER TABLE deliveries ENABLE ROW LEVEL SECURITY;

-- Create policies for couriers table
CREATE POLICY "Couriers can view own profile" ON couriers
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Couriers can update own profile" ON couriers
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Couriers can insert own profile" ON couriers
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create policies for deliveries table
CREATE POLICY "Couriers can view own deliveries" ON deliveries
  FOR SELECT USING (auth.uid() = courier_id);

CREATE POLICY "Couriers can update own deliveries" ON deliveries
  FOR UPDATE USING (auth.uid() = courier_id);
