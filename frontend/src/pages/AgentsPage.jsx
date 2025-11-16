import { useState } from 'react'
import Card from '../components/common/Card'
import Badge from '../components/common/Badge'
import { Bot, CheckCircle, AlertCircle, Clock } from 'lucide-react'

const agents = [
  { 
    id: 1, 
    name: 'Planner Agent', 
    status: 'active', 
    model: 'GPT-4o + mini',
    description: 'Task orchestration & daily planning',
    tasksToday: 45,
    lastRun: '2 min ago'
  },
  { 
    id: 2, 
    name: 'Multi-Sourcing Agent', 
    status: 'active', 
    model: 'GPT-4o + mini + Claude',
    description: 'Product discovery from multiple suppliers',
    tasksToday: 23,
    lastRun: '5 min ago'
  },
  { 
    id: 3, 
    name: 'Compliance Agent', 
    status: 'active', 
    model: 'mini + Claude',
    description: 'Pre-publication policy validation',
    tasksToday: 18,
    lastRun: '8 min ago'
  },
  { 
    id: 4, 
    name: 'Listing Agent', 
    status: 'active', 
    model: 'GPT-4o + mini',
    description: 'SEO-optimized listing creation',
    tasksToday: 31,
    lastRun: '3 min ago'
  },
  { 
    id: 5, 
    name: 'Pricing Agent', 
    status: 'active', 
    model: 'GPT-4o + mini',
    description: 'Dynamic pricing with competitor monitoring',
    tasksToday: 67,
    lastRun: '1 min ago'
  },
  { 
    id: 6, 
    name: 'Ops Agent', 
    status: 'active', 
    model: 'mini + GPT-4o',
    description: 'Order fulfillment automation',
    tasksToday: 12,
    lastRun: '15 min ago'
  },
  { 
    id: 7, 
    name: 'Reputation Agent', 
    status: 'warning', 
    model: 'GPT-4o + mini',
    description: 'Customer service & review monitoring',
    tasksToday: 8,
    lastRun: '45 min ago'
  },
  { 
    id: 8, 
    name: 'Analytics Agent', 
    status: 'active', 
    model: 'GPT-4o + mini',
    description: 'Reporting & business intelligence',
    tasksToday: 5,
    lastRun: '30 min ago'
  },
]

export default function AgentsPage() {
  const [selectedAgent, setSelectedAgent] = useState(null)

  const getStatusIcon = (status) => {
    switch (status) {
      case 'active':
        return <CheckCircle className="w-5 h-5 text-green-500" />
      case 'warning':
        return <AlertCircle className="w-5 h-5 text-yellow-500" />
      default:
        return <Clock className="w-5 h-5 text-gray-400" />
    }
  }

  const getStatusBadge = (status) => {
    switch (status) {
      case 'active':
        return <Badge variant="success">Active</Badge>
      case 'warning':
        return <Badge variant="warning">Warning</Badge>
      default:
        return <Badge variant="default">Idle</Badge>
    }
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">AI Agents</h1>
        <p className="mt-2 text-gray-600">Monitor and manage your AI agents</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card className="p-6">
          <div className="flex items-center space-x-3">
            <div className="p-2 bg-green-100 rounded-lg">
              <CheckCircle className="w-6 h-6 text-green-600" />
            </div>
            <div>
              <p className="text-sm text-gray-600">Active Agents</p>
              <p className="text-2xl font-bold text-gray-900">7</p>
            </div>
          </div>
        </Card>
        <Card className="p-6">
          <div className="flex items-center space-x-3">
            <div className="p-2 bg-blue-100 rounded-lg">
              <Bot className="w-6 h-6 text-blue-600" />
            </div>
            <div>
              <p className="text-sm text-gray-600">Tasks Today</p>
              <p className="text-2xl font-bold text-gray-900">209</p>
            </div>
          </div>
        </Card>
        <Card className="p-6">
          <div className="flex items-center space-x-3">
            <div className="p-2 bg-yellow-100 rounded-lg">
              <AlertCircle className="w-6 h-6 text-yellow-600" />
            </div>
            <div>
              <p className="text-sm text-gray-600">Warnings</p>
              <p className="text-2xl font-bold text-gray-900">1</p>
            </div>
          </div>
        </Card>
      </div>

      {/* Agents Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {agents.map((agent) => (
          <Card key={agent.id} className="p-6 hover:shadow-md transition-shadow cursor-pointer">
            <div className="flex items-start justify-between mb-4">
              <div className="flex items-center space-x-3">
                {getStatusIcon(agent.status)}
                <div>
                  <h3 className="text-lg font-semibold text-gray-900">{agent.name}</h3>
                  <p className="text-sm text-gray-500">{agent.model}</p>
                </div>
              </div>
              {getStatusBadge(agent.status)}
            </div>
            
            <p className="text-sm text-gray-600 mb-4">{agent.description}</p>
            
            <div className="flex items-center justify-between pt-4 border-t border-gray-200">
              <div>
                <p className="text-xs text-gray-500">Tasks Today</p>
                <p className="text-lg font-semibold text-gray-900">{agent.tasksToday}</p>
              </div>
              <div className="text-right">
                <p className="text-xs text-gray-500">Last Run</p>
                <p className="text-sm font-medium text-gray-900">{agent.lastRun}</p>
              </div>
            </div>
          </Card>
        ))}
      </div>
    </div>
  )
}
