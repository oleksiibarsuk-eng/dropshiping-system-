import Card from '../components/common/Card'
import { LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts'

const revenueData = [
  { date: 'Mon', revenue: 2400, margin: 600 },
  { date: 'Tue', revenue: 2800, margin: 700 },
  { date: 'Wed', revenue: 3200, margin: 800 },
  { date: 'Thu', revenue: 2900, margin: 725 },
  { date: 'Fri', revenue: 3500, margin: 875 },
  { date: 'Sat', revenue: 4100, margin: 1025 },
  { date: 'Sun', revenue: 3800, margin: 950 },
]

const llmUsageData = [
  { model: 'GPT-4o', calls: 1234, cost: 45.60 },
  { model: 'GPT-4.1-mini', calls: 4567, cost: 12.30 },
  { model: 'Claude 3.5', calls: 789, cost: 28.90 },
]

export default function AnalyticsPage() {
  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Analytics</h1>
        <p className="mt-2 text-gray-600">Business intelligence and insights</p>
      </div>

      {/* Key Metrics */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <Card className="p-6">
          <p className="text-sm text-gray-600">Total Revenue</p>
          <p className="mt-2 text-2xl font-bold text-gray-900">$22,800</p>
          <p className="mt-1 text-sm text-green-600">+15.3% from last week</p>
        </Card>
        <Card className="p-6">
          <p className="text-sm text-gray-600">Average Margin</p>
          <p className="mt-2 text-2xl font-bold text-gray-900">25.4%</p>
          <p className="mt-1 text-sm text-green-600">+2.1% from target</p>
        </Card>
        <Card className="p-6">
          <p className="text-sm text-gray-600">Orders</p>
          <p className="mt-2 text-2xl font-bold text-gray-900">143</p>
          <p className="mt-1 text-sm text-blue-600">12 pending</p>
        </Card>
        <Card className="p-6">
          <p className="text-sm text-gray-600">LLM Cost</p>
          <p className="mt-2 text-2xl font-bold text-gray-900">$86.80</p>
          <p className="mt-1 text-sm text-gray-600">6,590 calls</p>
        </Card>
      </div>

      {/* Revenue Chart */}
      <Card className="p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-6">Revenue & Margin Trends</h2>
        <ResponsiveContainer width="100%" height={300}>
          <LineChart data={revenueData}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="date" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Line type="monotone" dataKey="revenue" stroke="#0ea5e9" strokeWidth={2} name="Revenue ($)" />
            <Line type="monotone" dataKey="margin" stroke="#10b981" strokeWidth={2} name="Margin ($)" />
          </LineChart>
        </ResponsiveContainer>
      </Card>

      {/* LLM Usage */}
      <Card className="p-6">
        <h2 className="text-lg font-semibold text-gray-900 mb-6">LLM Usage & Costs</h2>
        <ResponsiveContainer width="100%" height={300}>
          <BarChart data={llmUsageData}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="model" />
            <YAxis yAxisId="left" orientation="left" stroke="#0ea5e9" />
            <YAxis yAxisId="right" orientation="right" stroke="#10b981" />
            <Tooltip />
            <Legend />
            <Bar yAxisId="left" dataKey="calls" fill="#0ea5e9" name="API Calls" />
            <Bar yAxisId="right" dataKey="cost" fill="#10b981" name="Cost ($)" />
          </BarChart>
        </ResponsiveContainer>
      </Card>

      {/* Details Table */}
      <Card>
        <div className="p-6 border-b border-gray-200">
          <h2 className="text-lg font-semibold text-gray-900">Model Usage Details</h2>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Model</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">API Calls</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Total Cost</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Avg Cost/Call</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {llmUsageData.map((model) => (
                <tr key={model.model} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{model.model}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">{model.calls.toLocaleString()}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">${model.cost.toFixed(2)}</td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-600">${(model.cost / model.calls).toFixed(4)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Card>
    </div>
  )
}
