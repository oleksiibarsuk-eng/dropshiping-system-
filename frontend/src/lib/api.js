import { supabase } from './supabase'

// Generic API helpers for Supabase

export const api = {
  // Get all records from a table
  async getAll(table, options = {}) {
    const { select = '*', filter, orderBy, limit } = options
    
    let query = supabase.from(table).select(select)
    
    if (filter) {
      Object.entries(filter).forEach(([key, value]) => {
        query = query.eq(key, value)
      })
    }
    
    if (orderBy) {
      query = query.order(orderBy.column, { ascending: orderBy.ascending ?? true })
    }
    
    if (limit) {
      query = query.limit(limit)
    }
    
    const { data, error } = await query
    
    if (error) throw error
    return data
  },

  // Get single record by ID
  async getById(table, id, select = '*') {
    const { data, error } = await supabase
      .from(table)
      .select(select)
      .eq('id', id)
      .single()
    
    if (error) throw error
    return data
  },

  // Create new record
  async create(table, data) {
    const { data: result, error } = await supabase
      .from(table)
      .insert(data)
      .select()
      .single()
    
    if (error) throw error
    return result
  },

  // Update record
  async update(table, id, data) {
    const { data: result, error } = await supabase
      .from(table)
      .update(data)
      .eq('id', id)
      .select()
      .single()
    
    if (error) throw error
    return result
  },

  // Delete record
  async delete(table, id) {
    const { error } = await supabase
      .from(table)
      .delete()
      .eq('id', id)
    
    if (error) throw error
  },

  // Call RPC function
  async rpc(functionName, params = {}) {
    const { data, error } = await supabase.rpc(functionName, params)
    
    if (error) throw error
    return data
  },

  // Get system state
  async getSystemState() {
    return this.rpc('get_system_state')
  },

  // Get top products
  async getTopProducts(limit = 10, days = 30) {
    return this.rpc('get_top_products', { p_limit: limit, p_days: days })
  },

  // Get agent stats
  async getAgentStats(days = 7) {
    return this.rpc('get_agent_stats', { p_days: days })
  },

  // Get daily analytics
  async getDailyAnalytics(date = null) {
    return this.rpc('get_daily_analytics', { p_date: date })
  },

  // Validate price change
  async validatePriceChange(listingId, newPrice, maxChangePercent = 30) {
    return this.rpc('validate_price_change', {
      p_listing_id: listingId,
      p_new_price: newPrice,
      p_max_change_percent: maxChangePercent
    })
  }
}

export default api
