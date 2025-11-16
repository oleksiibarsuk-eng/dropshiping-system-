import { useState, useEffect } from 'react'
import Card from '../components/common/Card'
import Badge from '../components/common/Badge'
import { Activity, TrendingUp, DollarSign, Package, AlertCircle } from 'lucide-react'

export default function OverviewPage() {
  const [metrics, setMetrics] = useState({
    activeAgents: 8,
    pendingTasks: 12,
    todayRevenue: 2845.50,
    activeListings: 156,
  })

  const [activities, setActivities] = useState([
    { id: 1, agent: 'Listing Agent', action: 'Created new listing', product: 'Sony A7 IV', time: '5 min ago', status: 'success' },
    { id: 2, agent: 'Pricing Agent', action: 'Updated price', product: 'Canon EOS R6', time: '12 min ago', status: 'success' },
    { id: 3, agent: 'Compliance Agent', action: 'Review required', product: 'Fuji X-T5', time: '18 min ago', status: 'warning' },
    { id: 4, agent: 'Ops Agent', action: 'Order fulfilled', product: 'Panasonic GH6', time: '25 min ago', status: 'success' },
  ])

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Overview</h1>
        <p className="mt-2 text-gray-600">Monitor your dropshipping operations</p>
      </div>

      {/* Metrics Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card className="p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Active Agents</p>
              <p className="mt-2 text-3xl font-bold text-gray-900">{metrics.activeAgents}</p>
            </div>
            <div className="p-3 bg-blue-100 rounded-lg">
              <Activity className="w-6 h-6 text-blue-600" />
            </div>
          </div>
        </Card>

        <Card className="p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Pending Tasks</p>
              <p className="mt-2 text-3xl font-bold text-gray-900">{metrics.pendingTasks}</p>
            </div>
            <div className="p-3 bg-yellow-100 rounded-lg">
              <AlertCircle className="w-6 h-6 text-yellow-600" />
            </div>
          </div>
        </Card>

        <Card className="p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Today's Revenue</p>
              <p className="mt-2 text-3xl font-bold text-gray-900">${metrics.todayRevenue.toFixed(2)}</p>
            </div>
            <div className="p-3 bg-green-100 rounded-lg">
              <DollarSign className="w-6 h-6 text-green-600" />
            </div>
          </div>
        </Card>

        <Card className="p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Active Listings</p>
              <p className="mt-2 text-3xl font-bold text-gray-900">{metrics.activeListings}</p>
            </div>
            <div className="p-3 bg-purple-100 rounded-lg">
              <Package className="w-6 h-6 text-purple-600" />
            </div>
          </div>
        </Card>
      </div>

      {/* Activity Feed */}
      <Card>
        <div className="p-6 border-b border-gray-200">
          <h2 className="text-lg font-semibold text-gray-900">Recent Activity</h2>
        </div>
        <div className="divide-y divide-gray-200">
          {activities.map((activity) => (
            <div key={activity.id} className="p-6 flex items-center justify-between hover:bg-gray-50 transition-colors">
              <div className="flex items-center space-x-4">
                <div className={`w-2 h-2 rounded-full ${
                  activity.status === 'success' ? 'bg-green-500' : 
                  activity.status === 'warning' ? 'bg-yellow-500' : 
                  'bg-red-500'
                }`} />
                <div>
                  <p className="text-sm font-medium text-gray-900">{activity.agent}</p>
                  <p className="text-sm text-gray-600">
                    {activity.action} • <span className="font-medium">{activity.product}</span>
                  </p>
                </div>
              </div>
              <div className="text-sm text-gray-500">{activity.time}</div>
            </div>
          ))}
        </div>
      </Card>
    </div>
  )
}
