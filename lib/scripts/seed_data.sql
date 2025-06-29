-- Insert sample courier data (replace with actual user IDs after authentication)
-- Note: You'll need to replace 'your-user-id-here' with actual user IDs from auth.users

-- Insert sample deliveries
INSERT INTO deliveries (order_id, courier_id, recipient_name, address, phone, status) VALUES
('ORD001', (SELECT id FROM auth.users LIMIT 1), 'John Doe', 'Jl. Merdeka No. 123, Jakarta Pusat', '081234567890', 'Menunggu'),
('ORD002', (SELECT id FROM auth.users LIMIT 1), 'Jane Smith', 'Jl. Sudirman No. 456, Jakarta Selatan', '081234567891', 'Dalam Perjalanan'),
('ORD003', (SELECT id FROM auth.users LIMIT 1), 'Bob Johnson', 'Jl. Thamrin No. 789, Jakarta Pusat', '081234567892', 'Selesai'),
('ORD004', (SELECT id FROM auth.users LIMIT 1), 'Alice Brown', 'Jl. Gatot Subroto No. 321, Jakarta Selatan', '081234567893', 'Menunggu'),
('ORD005', (SELECT id FROM auth.users LIMIT 1), 'Charlie Wilson', 'Jl. Kuningan No. 654, Jakarta Selatan', '081234567894', 'Dalam Perjalanan');
