-- Seed compliance rules
INSERT INTO compliance_rules (platform, rule_type, keyword, severity, action, description) VALUES
('eBay', 'PROHIBITED_KEYWORD', 'replica', 'HIGH', 'BLOCK', 'Replica items are prohibited on eBay'),
('eBay', 'PROHIBITED_KEYWORD', 'counterfeit', 'HIGH', 'BLOCK', 'Counterfeit items are prohibited'),
('eBay', 'PROHIBITED_KEYWORD', 'fake', 'HIGH', 'BLOCK', 'Fake items are prohibited'),
('eBay', 'HIGH_RISK_KEYWORD', 'gray market', 'MEDIUM', 'REVIEW', 'Gray market items require review'),
('eBay', 'HIGH_RISK_KEYWORD', 'warranty void', 'MEDIUM', 'REVIEW', 'Warranty disclaimers require review'),
('Shopify', 'PROHIBITED_KEYWORD', 'replica', 'HIGH', 'BLOCK', 'Replica items violate Shopify policies'),
('Shopify', 'PROHIBITED_KEYWORD', 'counterfeit', 'HIGH', 'BLOCK', 'Counterfeit items violate policies'),
('Meta', 'PROHIBITED_KEYWORD', 'replica', 'HIGH', 'BLOCK', 'Replica items violate Facebook Marketplace policies'),
('Meta', 'PROHIBITED_KEYWORD', 'counterfeit', 'HIGH', 'BLOCK', 'Counterfeit items are prohibited');

-- Seed sample suppliers
INSERT INTO suppliers (name, platform, url, reliability_score, risk_level, avg_shipping_days, is_active) VALUES
('eBay.de - CameraStore Munich', 'eBay', 'https://ebay.de/usr/camerastore-munich', 0.95, 'LOW', 5, TRUE),
('eBay.de - Berlin Photo Pro', 'eBay', 'https://ebay.de/usr/berlin-photo', 0.88, 'LOW', 7, TRUE),
('eBay.de - Hamburg Camera Outlet', 'eBay', 'https://ebay.de/usr/hamburg-camera', 0.82, 'MEDIUM', 6, TRUE);

-- Sample analytics snapshot (today)
INSERT INTO analytics_snapshots (snapshot_date, total_revenue, total_profit, total_orders, avg_margin_percent, active_listings, llm_total_calls, llm_total_cost)
VALUES (CURRENT_DATE, 2845.50, 711.38, 18, 25.0, 156, 6590, 86.80);
