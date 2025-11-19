-- Helper Functions and Procedures for Dropshipping System

-- Function to get system state for Planner Agent
CREATE OR REPLACE FUNCTION get_system_state()
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'active_listings', (SELECT COUNT(*) FROM listings WHERE status = 'ACTIVE'),
    'pending_orders', (SELECT COUNT(*) FROM orders WHERE status = 'PENDING'),
    'products_count', (SELECT COUNT(*) FROM products),
    'low_stock_count', (SELECT COUNT(*) FROM listings WHERE quantity < 5 AND status = 'ACTIVE'),
    'pending_tasks', (SELECT COUNT(*) FROM agents_tasks WHERE status = 'PENDING'),
    'needs_review', (SELECT COUNT(*) FROM agents_tasks WHERE needs_review = TRUE AND status != 'SUCCESS'),
    'error_count_24h', (SELECT COUNT(*) FROM errors WHERE created_at > NOW() - INTERVAL '24 hours' AND is_resolved = FALSE),
    'avg_margin', (SELECT AVG(current_margin_percent) FROM products WHERE status = 'ACTIVE'),
    'total_revenue_today', (SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE DATE(created_at) = CURRENT_DATE)
  ) INTO result;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Function to get or create supplier
CREATE OR REPLACE FUNCTION get_or_create_supplier(
  p_name VARCHAR,
  p_platform VARCHAR,
  p_url TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_supplier_id UUID;
BEGIN
  -- Try to find existing supplier
  SELECT id INTO v_supplier_id
  FROM suppliers
  WHERE name = p_name AND platform = p_platform;
  
  -- If not found, create new supplier
  IF v_supplier_id IS NULL THEN
    INSERT INTO suppliers (name, platform, url, reliability_score, risk_level, is_active)
    VALUES (p_name, p_platform, p_url, 0.5, 'MEDIUM', TRUE)
    RETURNING id INTO v_supplier_id;
  END IF;
  
  RETURN v_supplier_id;
END;
$$ LANGUAGE plpgsql;

-- Function to calculate product margin
CREATE OR REPLACE FUNCTION calculate_margin(
  p_cost_price DECIMAL,
  p_selling_price DECIMAL
)
RETURNS DECIMAL AS $$
BEGIN
  IF p_cost_price = 0 OR p_cost_price IS NULL THEN
    RETURN 0;
  END IF;
  
  RETURN ROUND(((p_selling_price - p_cost_price) / p_cost_price * 100)::NUMERIC, 2);
END;
$$ LANGUAGE plpgsql;

-- Function to validate price change
CREATE OR REPLACE FUNCTION validate_price_change(
  p_listing_id UUID,
  p_new_price DECIMAL,
  p_max_change_percent DECIMAL DEFAULT 30
)
RETURNS JSON AS $$
DECLARE
  v_current_price DECIMAL;
  v_cost_price DECIMAL;
  v_min_margin DECIMAL;
  v_change_percent DECIMAL;
  v_new_margin DECIMAL;
  v_result JSON;
BEGIN
  -- Get current price and cost
  SELECT l.price, p.cost_price, p.minimal_margin_percent
  INTO v_current_price, v_cost_price, v_min_margin
  FROM listings l
  JOIN products p ON l.product_id = p.id
  WHERE l.id = p_listing_id;
  
  -- Calculate change percentage
  IF v_current_price > 0 THEN
    v_change_percent := ABS((p_new_price - v_current_price) / v_current_price * 100);
  ELSE
    v_change_percent := 0;
  END IF;
  
  -- Calculate new margin
  v_new_margin := calculate_margin(v_cost_price, p_new_price);
  
  -- Build result
  SELECT json_build_object(
    'valid', (v_change_percent <= p_max_change_percent AND v_new_margin >= v_min_margin),
    'change_percent', ROUND(v_change_percent, 2),
    'new_margin', v_new_margin,
    'min_margin', v_min_margin,
    'needs_review', (v_change_percent > p_max_change_percent OR v_new_margin < v_min_margin),
    'reason', CASE
      WHEN v_change_percent > p_max_change_percent THEN 'Price change exceeds ' || p_max_change_percent || '%'
      WHEN v_new_margin < v_min_margin THEN 'Margin below minimum threshold'
      ELSE 'Valid'
    END
  ) INTO v_result;
  
  RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Function to get top performing products
CREATE OR REPLACE FUNCTION get_top_products(
  p_limit INT DEFAULT 10,
  p_days INT DEFAULT 30
)
RETURNS TABLE (
  product_id UUID,
  product_title VARCHAR,
  total_sales BIGINT,
  total_revenue DECIMAL,
  total_profit DECIMAL,
  avg_margin DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.title,
    COUNT(o.id) as total_sales,
    COALESCE(SUM(o.total_amount), 0) as total_revenue,
    COALESCE(SUM(o.profit_amount), 0) as total_profit,
    ROUND(AVG(o.profit_amount / NULLIF(o.total_amount, 0) * 100)::NUMERIC, 2) as avg_margin
  FROM products p
  LEFT JOIN listings l ON p.id = l.product_id
  LEFT JOIN orders o ON l.id = o.listing_id
  WHERE o.created_at > NOW() - (p_days || ' days')::INTERVAL
  GROUP BY p.id
  ORDER BY total_profit DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Function to get agent performance stats
CREATE OR REPLACE FUNCTION get_agent_stats(
  p_days INT DEFAULT 7
)
RETURNS TABLE (
  agent_name VARCHAR,
  total_tasks BIGINT,
  successful_tasks BIGINT,
  failed_tasks BIGINT,
  needs_review_tasks BIGINT,
  success_rate DECIMAL,
  total_tokens BIGINT,
  total_cost DECIMAL,
  avg_cost_per_task DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    at.agent_name,
    COUNT(*) as total_tasks,
    SUM(CASE WHEN status = 'SUCCESS' THEN 1 ELSE 0 END) as successful_tasks,
    SUM(CASE WHEN status = 'FAILED' THEN 1 ELSE 0 END) as failed_tasks,
    SUM(CASE WHEN needs_review = TRUE THEN 1 ELSE 0 END) as needs_review_tasks,
    ROUND((SUM(CASE WHEN status = 'SUCCESS' THEN 1 ELSE 0 END)::DECIMAL / COUNT(*) * 100)::NUMERIC, 2) as success_rate,
    COALESCE(SUM(llm_tokens_used), 0) as total_tokens,
    COALESCE(SUM(llm_cost), 0) as total_cost,
    ROUND((COALESCE(SUM(llm_cost), 0) / NULLIF(COUNT(*), 0))::NUMERIC, 4) as avg_cost_per_task
  FROM agents_tasks at
  WHERE created_at > NOW() - (p_days || ' days')::INTERVAL
  GROUP BY at.agent_name
  ORDER BY total_tasks DESC;
END;
$$ LANGUAGE plpgsql;

-- Function to check compliance issues
CREATE OR REPLACE FUNCTION check_listing_compliance(
  p_listing_id UUID
)
RETURNS JSON AS $$
DECLARE
  v_result JSON;
  v_title VARCHAR;
  v_description TEXT;
  v_platform VARCHAR;
  v_issues_count INT;
BEGIN
  -- Get listing data
  SELECT l.title, l.description, l.platform
  INTO v_title, v_description, v_platform
  FROM listings l
  WHERE l.id = p_listing_id;
  
  -- Count compliance issues
  SELECT COUNT(*)
  INTO v_issues_count
  FROM compliance_issues
  WHERE entity_type = 'listing'
  AND entity_id = p_listing_id
  AND is_resolved = FALSE;
  
  -- Build result
  SELECT json_build_object(
    'listing_id', p_listing_id,
    'has_issues', v_issues_count > 0,
    'issues_count', v_issues_count,
    'requires_review', v_issues_count > 0
  ) INTO v_result;
  
  RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Function to get daily analytics
CREATE OR REPLACE FUNCTION get_daily_analytics(p_date DATE DEFAULT CURRENT_DATE)
RETURNS JSON AS $$
DECLARE
  v_result JSON;
BEGIN
  SELECT json_build_object(
    'date', p_date,
    'orders', (
      SELECT json_build_object(
        'count', COUNT(*),
        'revenue', COALESCE(SUM(total_amount), 0),
        'profit', COALESCE(SUM(profit_amount), 0),
        'avg_order_value', ROUND(AVG(total_amount)::NUMERIC, 2)
      )
      FROM orders
      WHERE DATE(created_at) = p_date
    ),
    'listings', (
      SELECT json_build_object(
        'created', COUNT(*),
        'platforms', json_object_agg(platform, cnt)
      )
      FROM (
        SELECT platform, COUNT(*) as cnt
        FROM listings
        WHERE DATE(created_at) = p_date
        GROUP BY platform
      ) sub
    ),
    'products', (
      SELECT json_build_object(
        'sourced', COUNT(*)
      )
      FROM products
      WHERE DATE(created_at) = p_date
    ),
    'agents', (
      SELECT json_object_agg(agent_name, task_count)
      FROM (
        SELECT agent_name, COUNT(*) as task_count
        FROM agents_tasks
        WHERE DATE(created_at) = p_date
        GROUP BY agent_name
      ) sub
    ),
    'llm_usage', (
      SELECT json_build_object(
        'total_calls', COUNT(*),
        'total_tokens', COALESCE(SUM(llm_tokens_used), 0),
        'total_cost', COALESCE(SUM(llm_cost), 0),
        'by_model', json_object_agg(llm_model, model_data)
      )
      FROM (
        SELECT 
          llm_model,
          json_build_object(
            'calls', COUNT(*),
            'tokens', SUM(llm_tokens_used),
            'cost', SUM(llm_cost)
          ) as model_data
        FROM agents_tasks
        WHERE DATE(created_at) = p_date
        AND llm_model IS NOT NULL
        GROUP BY llm_model
      ) sub
    )
  ) INTO v_result;
  
  RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- Function to update supplier reliability score
CREATE OR REPLACE FUNCTION update_supplier_score(
  p_supplier_id UUID,
  p_order_success BOOLEAN
)
RETURNS VOID AS $$
DECLARE
  v_current_score DECIMAL;
  v_new_score DECIMAL;
BEGIN
  -- Get current score
  SELECT reliability_score INTO v_current_score
  FROM suppliers
  WHERE id = p_supplier_id;
  
  -- Calculate new score (weighted average: 90% old, 10% new)
  IF p_order_success THEN
    v_new_score := v_current_score * 0.9 + 1.0 * 0.1;
  ELSE
    v_new_score := v_current_score * 0.9 + 0.0 * 0.1;
  END IF;
  
  -- Update supplier
  UPDATE suppliers
  SET 
    reliability_score = v_new_score,
    risk_level = CASE
      WHEN v_new_score >= 0.8 THEN 'LOW'
      WHEN v_new_score >= 0.5 THEN 'MEDIUM'
      ELSE 'HIGH'
    END
  WHERE id = p_supplier_id;
END;
$$ LANGUAGE plpgsql;

-- Function to archive old logs (cleanup)
CREATE OR REPLACE FUNCTION archive_old_logs(p_days INT DEFAULT 90)
RETURNS INT AS $$
DECLARE
  v_deleted_count INT;
BEGIN
  DELETE FROM logs
  WHERE created_at < NOW() - (p_days || ' days')::INTERVAL
  AND level != 'error';
  
  GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
  
  RETURN v_deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Create view for dashboard overview
CREATE OR REPLACE VIEW dashboard_overview AS
SELECT
  (SELECT COUNT(*) FROM listings WHERE status = 'ACTIVE') as active_listings,
  (SELECT COUNT(*) FROM orders WHERE status = 'PENDING') as pending_orders,
  (SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE DATE(created_at) = CURRENT_DATE) as today_revenue,
  (SELECT COALESCE(SUM(profit_amount), 0) FROM orders WHERE DATE(created_at) = CURRENT_DATE) as today_profit,
  (SELECT COUNT(*) FROM agents_tasks WHERE needs_review = TRUE AND status != 'SUCCESS') as tasks_needing_review,
  (SELECT COUNT(*) FROM errors WHERE created_at > NOW() - INTERVAL '24 hours' AND is_resolved = FALSE) as recent_errors,
  (SELECT ROUND(AVG(current_margin_percent)::NUMERIC, 2) FROM products WHERE status = 'ACTIVE') as avg_margin,
  (SELECT COUNT(DISTINCT agent_name) FROM agents_tasks WHERE created_at > NOW() - INTERVAL '1 hour') as active_agents;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_system_state() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_or_create_supplier(VARCHAR, VARCHAR, TEXT) TO service_role;
GRANT EXECUTE ON FUNCTION calculate_margin(DECIMAL, DECIMAL) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION validate_price_change(UUID, DECIMAL, DECIMAL) TO service_role;
GRANT EXECUTE ON FUNCTION get_top_products(INT, INT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION get_agent_stats(INT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION check_listing_compliance(UUID) TO service_role;
GRANT EXECUTE ON FUNCTION get_daily_analytics(DATE) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION update_supplier_score(UUID, BOOLEAN) TO service_role;
GRANT EXECUTE ON FUNCTION archive_old_logs(INT) TO service_role;
GRANT SELECT ON dashboard_overview TO anon, authenticated;
