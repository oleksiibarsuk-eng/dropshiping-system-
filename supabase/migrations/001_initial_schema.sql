-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Products table
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sku VARCHAR(255) UNIQUE NOT NULL,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    category VARCHAR(255),
    brand VARCHAR(255),
    cost_price DECIMAL(10, 2) NOT NULL,
    selling_price DECIMAL(10, 2) NOT NULL,
    minimal_margin_percent DECIMAL(5, 2) DEFAULT 20.0,
    current_margin_percent DECIMAL(5, 2),
    status VARCHAR(50) DEFAULT 'DRAFT',
    source_platform VARCHAR(50),
    source_url TEXT,
    image_urls TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Suppliers table
CREATE TABLE suppliers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    platform VARCHAR(50) NOT NULL,
    url TEXT,
    reliability_score DECIMAL(3, 2) DEFAULT 0.5,
    risk_level VARCHAR(20) DEFAULT 'MEDIUM',
    avg_shipping_days INT,
    notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Product-Supplier relationship
CREATE TABLE product_suppliers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    supplier_id UUID REFERENCES suppliers(id) ON DELETE CASCADE,
    supplier_sku VARCHAR(255),
    supplier_price DECIMAL(10, 2),
    is_primary BOOLEAN DEFAULT FALSE,
    last_checked_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(product_id, supplier_id)
);

-- Listings table
CREATE TABLE listings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    platform VARCHAR(50) NOT NULL,
    platform_listing_id VARCHAR(255),
    title VARCHAR(500) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    quantity INT DEFAULT 0,
    status VARCHAR(50) DEFAULT 'DRAFT',
    seo_tags TEXT[],
    published_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Orders table
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    listing_id UUID REFERENCES listings(id),
    platform VARCHAR(50) NOT NULL,
    platform_order_id VARCHAR(255) UNIQUE NOT NULL,
    customer_email VARCHAR(255),
    customer_name VARCHAR(255),
    total_amount DECIMAL(10, 2) NOT NULL,
    profit_amount DECIMAL(10, 2),
    status VARCHAR(50) DEFAULT 'PENDING',
    tracking_number VARCHAR(255),
    shipped_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Agent tasks table
CREATE TABLE agents_tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    agent_name VARCHAR(100) NOT NULL,
    task_type VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id UUID,
    status VARCHAR(50) DEFAULT 'PENDING',
    priority VARCHAR(20) DEFAULT 'MEDIUM',
    input_data JSONB,
    output_data JSONB,
    llm_model VARCHAR(100),
    llm_tokens_used INT,
    llm_cost DECIMAL(10, 4),
    error_message TEXT,
    needs_review BOOLEAN DEFAULT FALSE,
    review_reason TEXT,
    reviewed_by VARCHAR(255),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

-- Errors table
CREATE TABLE errors (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source VARCHAR(100) NOT NULL,
    error_type VARCHAR(100) NOT NULL,
    error_message TEXT NOT NULL,
    stack_trace TEXT,
    context JSONB,
    severity VARCHAR(20) DEFAULT 'ERROR',
    is_resolved BOOLEAN DEFAULT FALSE,
    resolved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Logs table
CREATE TABLE logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    level VARCHAR(20) NOT NULL,
    source VARCHAR(100) NOT NULL,
    message TEXT NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Compliance rules table
CREATE TABLE compliance_rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    platform VARCHAR(50) NOT NULL,
    rule_type VARCHAR(100) NOT NULL,
    keyword VARCHAR(255),
    category VARCHAR(255),
    severity VARCHAR(20) DEFAULT 'MEDIUM',
    action VARCHAR(50) DEFAULT 'REVIEW',
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Compliance issues table
CREATE TABLE compliance_issues (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    rule_id UUID REFERENCES compliance_rules(id),
    verdict VARCHAR(50),
    issues JSONB,
    suggested_changes JSONB,
    is_resolved BOOLEAN DEFAULT FALSE,
    resolved_by VARCHAR(255),
    resolved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Analytics snapshots table
CREATE TABLE analytics_snapshots (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    snapshot_date DATE NOT NULL,
    total_revenue DECIMAL(10, 2),
    total_profit DECIMAL(10, 2),
    total_orders INT,
    avg_margin_percent DECIMAL(5, 2),
    active_listings INT,
    llm_total_calls INT,
    llm_total_cost DECIMAL(10, 2),
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(snapshot_date)
);

-- Create indexes for better performance
CREATE INDEX idx_products_status ON products(status);
CREATE INDEX idx_products_brand ON products(brand);
CREATE INDEX idx_listings_platform ON listings(platform);
CREATE INDEX idx_listings_status ON listings(status);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_platform_order_id ON orders(platform_order_id);
CREATE INDEX idx_agents_tasks_status ON agents_tasks(status);
CREATE INDEX idx_agents_tasks_agent_name ON agents_tasks(agent_name);
CREATE INDEX idx_agents_tasks_needs_review ON agents_tasks(needs_review);
CREATE INDEX idx_errors_is_resolved ON errors(is_resolved);
CREATE INDEX idx_compliance_issues_is_resolved ON compliance_issues(is_resolved);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add triggers for updated_at
CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_suppliers_updated_at BEFORE UPDATE ON suppliers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_listings_updated_at BEFORE UPDATE ON listings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_agents_tasks_updated_at BEFORE UPDATE ON agents_tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_compliance_rules_updated_at BEFORE UPDATE ON compliance_rules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
