import { useState } from 'react'
import Card from '../components/common/Card'
import Badge from '../components/common/Badge'
import Button from '../components/common/Button'
import { Filter, Search } from 'lucide-react'

const tasks = [
  { 
    id: 1, 
    title: 'Review listing compliance', 
    agent: 'Compliance Agent',
    product: 'Sony A7 IV Body',
    status: 'NEEDS_REVIEW',
    priority: 'high',
    createdAt: '10 min ago',
    reason: 'High-risk category detected'
  },
  { 
    id: 2, 
    title: 'Price adjustment review', 
    agent: 'Pricing Agent',
    product: 'Canon EOS R6 Mark II',
    status: 'NEEDS_REVIEW',
    priority: 'medium',
    createdAt: '25 min ago',
    reason: 'Price change >30%'
  },
  { 
    id: 3, 
    title: 'Create listing for new product', 
    agent: 'Listing Agent',
    product: 'Fuji X-T5 Kit',
    status: 'IN_PROGRESS',
    priority: 'medium',
    createdAt: '1 hour ago'
  },
  { 
    id: 4, 
    title: 'Order fulfillment', 
    agent: 'Ops Agent',
    product: 'Panasonic GH6',
    status: 'SUCCESS',
    priority: 'high',
    createdAt: '2 hours ago'
  },
  { 
    id: 5, 
    title: 'Source products', 
    agent: 'Multi-Sourcing Agent',
    product: 'Ricoh GR IIIx',
    status: 'PENDING',
    priority: 'low',
    createdAt: '3 hours ago'
  },
]

export default function TasksPage() {
  const [filter, setFilter] = useState('all')
  const [searchTerm, setSearchTerm] = useState('')

  const getStatusBadge = (status) => {
    switch (status) {
      case 'SUCCESS':
        return <Badge variant="success">Success</Badge>
      case 'IN_PROGRESS':
        return <Badge variant="info">In Progress</Badge>
      case 'NEEDS_REVIEW':
        return <Badge variant="warning">Needs Review</Badge>
      case 'FAILED':
        return <Badge variant="danger">Failed</Badge>
      default:
        return <Badge variant="default">Pending</Badge>
    }
  }

  const getPriorityBadge = (priority) => {
    switch (priority) {
      case 'high':
        return <Badge variant="danger">High</Badge>
      case 'medium':
        return <Badge variant="warning">Medium</Badge>
      default:
        return <Badge variant="default">Low</Badge>
    }
  }

  const filteredTasks = tasks.filter(task => {
    if (filter !== 'all' && task.status !== filter) return false
    if (searchTerm && !task.title.toLowerCase().includes(searchTerm.toLowerCase()) &&
        !task.product.toLowerCase().includes(searchTerm.toLowerCase())) return false
    return true
  })

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Tasks</h1>
        <p className="mt-2 text-gray-600">Manage and review agent tasks</p>
      </div>

      {/* Filters */}
      <Card className="p-6">
        <div className="flex flex-col md:flex-row gap-4">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="text"
              placeholder="Search tasks or products..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
            />
          </div>
          <div className="flex gap-2">
            <Button
              variant={filter === 'all' ? 'primary' : 'ghost'}
              onClick={() => setFilter('all')}
            >
              All
            </Button>
            <Button
              variant={filter === 'NEEDS_REVIEW' ? 'primary' : 'ghost'}
              onClick={() => setFilter('NEEDS_REVIEW')}
            >
              Needs Review
            </Button>
            <Button
              variant={filter === 'IN_PROGRESS' ? 'primary' : 'ghost'}
              onClick={() => setFilter('IN_PROGRESS')}
            >
              In Progress
            </Button>
            <Button
              variant={filter === 'SUCCESS' ? 'primary' : 'ghost'}
              onClick={() => setFilter('SUCCESS')}
            >
              Completed
            </Button>
          </div>
        </div>
      </Card>

      {/* Tasks List */}
      <Card>
        <div className="divide-y divide-gray-200">
          {filteredTasks.length === 0 ? (
            <div className="p-12 text-center">
              <p className="text-gray-500">No tasks found</p>
            </div>
          ) : (
            filteredTasks.map((task) => (
              <div key={task.id} className="p-6 hover:bg-gray-50 transition-colors">
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <div className="flex items-center gap-3 mb-2">
                      <h3 className="text-lg font-semibold text-gray-900">{task.title}</h3>
                      {getStatusBadge(task.status)}
                      {getPriorityBadge(task.priority)}
                    </div>
                    <p className="text-sm text-gray-600 mb-1">
                      <span className="font-medium">{task.agent}</span> • {task.product}
                    </p>
                    {task.reason && (
                      <p className="text-sm text-yellow-700 bg-yellow-50 inline-block px-2 py-1 rounded">
                        {task.reason}
                      </p>
                    )}
                  </div>
                  <div className="flex items-center gap-3">
                    <span className="text-sm text-gray-500">{task.createdAt}</span>
                    {task.status === 'NEEDS_REVIEW' && (
                      <div className="flex gap-2">
                        <Button size="sm" variant="primary">Review</Button>
                        <Button size="sm" variant="secondary">Dismiss</Button>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            ))
          )}
        </div>
      </Card>
    </div>
  )
}
