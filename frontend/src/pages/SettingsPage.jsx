import { useState } from 'react'
import Card from '../components/common/Card'
import Button from '../components/common/Button'
import Badge from '../components/common/Badge'
import { Save, Check, X } from 'lucide-react'

export default function SettingsPage() {
  const [settings, setSettings] = useState({
    minimalMargin: 20,
    maxPriceChange: 30,
    autoPublish: false,
    telegramNotifications: true,
  })

  const [integrations, setIntegrations] = useState([
    { name: 'Supabase', status: 'connected', lastCheck: '2 min ago' },
    { name: 'OpenRouter', status: 'connected', lastCheck: '5 min ago' },
    { name: 'eBay API', status: 'connected', lastCheck: '10 min ago' },
    { name: 'Shopify', status: 'connected', lastCheck: '15 min ago' },
    { name: 'Meta Business', status: 'error', lastCheck: '1 hour ago', error: 'Token expired' },
    { name: 'Telegram Bot', status: 'connected', lastCheck: '3 min ago' },
  ])

  const handleSave = () => {
    alert('Settings saved!')
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">Settings</h1>
        <p className="mt-2 text-gray-600">Configure your system settings and integrations</p>
      </div>

      {/* Business Rules */}
      <Card>
        <div className="p-6 border-b border-gray-200">
          <h2 className="text-lg font-semibold text-gray-900">Business Rules</h2>
        </div>
        <div className="p-6 space-y-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Minimal Margin (%)
            </label>
            <input
              type="number"
              value={settings.minimalMargin}
              onChange={(e) => setSettings({ ...settings, minimalMargin: Number(e.target.value) })}
              className="w-full md:w-64 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
            />
            <p className="mt-1 text-sm text-gray-500">
              Minimum profit margin required for all products
            </p>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Max Price Change (%)
            </label>
            <input
              type="number"
              value={settings.maxPriceChange}
              onChange={(e) => setSettings({ ...settings, maxPriceChange: Number(e.target.value) })}
              className="w-full md:w-64 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary-500"
            />
            <p className="mt-1 text-sm text-gray-500">
              Price changes above this require manual review
            </p>
          </div>

          <div className="flex items-center space-x-3">
            <input
              type="checkbox"
              id="autoPublish"
              checked={settings.autoPublish}
              onChange={(e) => setSettings({ ...settings, autoPublish: e.target.checked })}
              className="w-4 h-4 text-primary-600 border-gray-300 rounded focus:ring-primary-500"
            />
            <label htmlFor="autoPublish" className="text-sm font-medium text-gray-700">
              Auto-publish approved listings
            </label>
          </div>

          <div className="flex items-center space-x-3">
            <input
              type="checkbox"
              id="telegramNotifications"
              checked={settings.telegramNotifications}
              onChange={(e) => setSettings({ ...settings, telegramNotifications: e.target.checked })}
              className="w-4 h-4 text-primary-600 border-gray-300 rounded focus:ring-primary-500"
            />
            <label htmlFor="telegramNotifications" className="text-sm font-medium text-gray-700">
              Enable Telegram notifications
            </label>
          </div>

          <div className="pt-4">
            <Button onClick={handleSave}>
              <Save className="w-4 h-4 mr-2" />
              Save Settings
            </Button>
          </div>
        </div>
      </Card>

      {/* Integrations */}
      <Card>
        <div className="p-6 border-b border-gray-200">
          <h2 className="text-lg font-semibold text-gray-900">Integrations</h2>
        </div>
        <div className="divide-y divide-gray-200">
          {integrations.map((integration) => (
            <div key={integration.name} className="p-6 flex items-center justify-between">
              <div className="flex items-center space-x-4">
                {integration.status === 'connected' ? (
                  <div className="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
                    <Check className="w-5 h-5 text-green-600" />
                  </div>
                ) : (
                  <div className="w-10 h-10 bg-red-100 rounded-lg flex items-center justify-center">
                    <X className="w-5 h-5 text-red-600" />
                  </div>
                )}
                <div>
                  <h3 className="text-sm font-medium text-gray-900">{integration.name}</h3>
                  <p className="text-sm text-gray-500">
                    Last check: {integration.lastCheck}
                  </p>
                  {integration.error && (
                    <p className="text-sm text-red-600 mt-1">{integration.error}</p>
                  )}
                </div>
              </div>
              <div className="flex items-center space-x-3">
                {integration.status === 'connected' ? (
                  <Badge variant="success">Connected</Badge>
                ) : (
                  <Badge variant="danger">Error</Badge>
                )}
                <Button size="sm" variant="secondary">
                  {integration.status === 'connected' ? 'Test' : 'Reconnect'}
                </Button>
              </div>
            </div>
          ))}
        </div>
      </Card>

      {/* Compliance Rules */}
      <Card>
        <div className="p-6 border-b border-gray-200">
          <h2 className="text-lg font-semibold text-gray-900">Compliance Rules</h2>
        </div>
        <div className="p-6">
          <p className="text-sm text-gray-600 mb-4">
            High-risk keywords and categories that trigger compliance review
          </p>
          <div className="flex flex-wrap gap-2 mb-4">
            {['replica', 'counterfeit', 'gray market', 'refurbished', 'warranty void'].map((keyword) => (
              <Badge key={keyword} variant="warning">{keyword}</Badge>
            ))}
          </div>
          <Button size="sm" variant="secondary">
            Manage Rules
          </Button>
        </div>
      </Card>
    </div>
  )
}
