"use client"

import { useState } from "react"
import { motion } from "framer-motion"
import { Star, Check, Crown, Zap, CreditCard, Calendar, Download } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { LivingBackground } from "@/components/living-background"
import { PageContainer } from "@/components/page-container"
import { ProNavigation } from "@/components/pro-navigation"
import { withLawyerAuth } from "@/lib/lawyer-auth"

const plans = [
  {
    name: "Starter",
    price: "₹1,999",
    period: "month",
    description: "Perfect for solo practitioners",
    features: [
      "Up to 15 case leads per month",
      "Basic profile visibility",
      "Email support",
      "Standard analytics",
      "Mobile app access",
    ],
    popular: false,
    icon: <Star className="w-6 h-6" />,
    color: "blue",
  },
  {
    name: "Professional",
    price: "₹4,999",
    period: "month",
    description: "For growing law firms",
    features: [
      "Up to 50 case leads per month",
      "Enhanced profile with verification badge",
      "Priority support",
      "Advanced analytics & insights",
      "Client management tools",
      "Custom branding options",
    ],
    popular: true,
    icon: <Crown className="w-6 h-6" />,
    color: "purple",
  },
  {
    name: "Enterprise",
    price: "₹9,999",
    period: "month",
    description: "For established firms",
    features: [
      "Unlimited case leads",
      "Premium profile placement",
      "24/7 dedicated support",
      "Custom analytics dashboard",
      "Team collaboration tools",
      "API access",
      "White-label solutions",
    ],
    popular: false,
    icon: <Zap className="w-6 h-6" />,
    color: "gold",
  },
]

const billingHistory = [
  {
    id: "1",
    date: "2024-01-15",
    amount: "₹4,999",
    plan: "Professional",
    status: "Paid",
    invoice: "INV-2024-001",
  },
  {
    id: "2",
    date: "2023-12-15",
    amount: "₹4,999",
    plan: "Professional",
    status: "Paid",
    invoice: "INV-2023-012",
  },
  {
    id: "3",
    date: "2023-11-15",
    amount: "₹4,999",
    plan: "Professional",
    status: "Paid",
    invoice: "INV-2023-011",
  },
]

function ProBillingPage() {
  const [selectedPlan, setSelectedPlan] = useState("Professional")
  const [billingCycle, setBillingCycle] = useState("monthly")

  return (
    <>
      <LivingBackground />
      <PageContainer>
        <ProNavigation />

        <div className="pt-20 pb-12">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8"
          >
            <div className="text-center mb-12">
              <motion.h1
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                className="text-4xl md:text-5xl font-bold bg-gradient-to-r from-blue-400 via-purple-500 to-cyan-400 bg-clip-text text-transparent mb-4"
              >
                Billing & Subscription
              </motion.h1>
              <motion.p
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.1 }}
                className="text-xl text-gray-300 max-w-3xl mx-auto"
              >
                Manage your subscription and billing preferences
              </motion.p>
            </div>

            <Tabs defaultValue="plans" className="w-full">
              <TabsList className="grid w-full grid-cols-3 mb-8">
                <TabsTrigger value="plans">Subscription Plans</TabsTrigger>
                <TabsTrigger value="current">Current Plan</TabsTrigger>
                <TabsTrigger value="history">Billing History</TabsTrigger>
              </TabsList>

              <TabsContent value="plans">
                <div className="mb-8 flex justify-center">
                  <div className="bg-gray-800/50 backdrop-blur-sm rounded-lg p-1 border border-gray-700">
                    <button
                      onClick={() => setBillingCycle("monthly")}
                      className={`px-4 py-2 rounded-md transition-all ${
                        billingCycle === "monthly" ? "bg-blue-600 text-white" : "text-gray-400 hover:text-white"
                      }`}
                    >
                      Monthly
                    </button>
                    <button
                      onClick={() => setBillingCycle("yearly")}
                      className={`px-4 py-2 rounded-md transition-all ${
                        billingCycle === "yearly" ? "bg-blue-600 text-white" : "text-gray-400 hover:text-white"
                      }`}
                    >
                      Yearly (Save 20%)
                    </button>
                  </div>
                </div>

                <div className="grid md:grid-cols-3 gap-8">
                  {plans.map((plan, index) => (
                    <motion.div
                      key={plan.name}
                      initial={{ opacity: 0, y: 20 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: index * 0.1 }}
                      className="relative"
                    >
                      {plan.popular && (
                        <div className="absolute -top-4 left-1/2 transform -translate-x-1/2">
                          <Badge className="bg-gradient-to-r from-purple-500 to-pink-500 text-white px-4 py-1">
                            Most Popular
                          </Badge>
                        </div>
                      )}

                      <Card
                        className={`h-full bg-gray-900/50 backdrop-blur-sm border-gray-700 hover:border-gray-600 transition-all duration-300 ${
                          plan.popular ? "ring-2 ring-purple-500/50" : ""
                        }`}
                      >
                        <CardHeader className="text-center pb-4">
                          <div
                            className={`w-12 h-12 mx-auto mb-4 rounded-full bg-gradient-to-r ${
                              plan.color === "blue"
                                ? "from-blue-500 to-cyan-500"
                                : plan.color === "purple"
                                  ? "from-purple-500 to-pink-500"
                                  : "from-yellow-500 to-orange-500"
                            } flex items-center justify-center`}
                          >
                            {plan.icon}
                          </div>
                          <CardTitle className="text-2xl font-bold text-white">{plan.name}</CardTitle>
                          <CardDescription className="text-gray-400">{plan.description}</CardDescription>
                          <div className="mt-4">
                            <span className="text-4xl font-bold text-white">
                              {billingCycle === "yearly"
                                ? `₹${Math.floor(Number.parseInt(plan.price.replace("₹", "").replace(",", "")) * 0.8).toLocaleString()}`
                                : plan.price}
                            </span>
                            <span className="text-gray-400">/{billingCycle === "yearly" ? "year" : plan.period}</span>
                          </div>
                        </CardHeader>

                        <CardContent>
                          <ul className="space-y-3 mb-6">
                            {plan.features.map((feature, featureIndex) => (
                              <li key={featureIndex} className="flex items-center text-gray-300">
                                <Check className="w-5 h-5 text-green-500 mr-3 flex-shrink-0" />
                                {feature}
                              </li>
                            ))}
                          </ul>

                          <Button
                            className={`w-full ${
                              plan.popular
                                ? "bg-gradient-to-r from-purple-500 to-pink-500 hover:from-purple-600 hover:to-pink-600"
                                : "bg-gray-700 hover:bg-gray-600"
                            } text-white`}
                            onClick={() => setSelectedPlan(plan.name)}
                          >
                            {selectedPlan === plan.name ? "Current Plan" : "Choose Plan"}
                          </Button>
                        </CardContent>
                      </Card>
                    </motion.div>
                  ))}
                </div>
              </TabsContent>

              <TabsContent value="current">
                <Card className="bg-gray-900/50 backdrop-blur-sm border-gray-700">
                  <CardHeader>
                    <CardTitle className="text-white flex items-center gap-2">
                      <Crown className="w-6 h-6 text-purple-500" />
                      Current Subscription
                    </CardTitle>
                  </CardHeader>
                  <CardContent className="space-y-6">
                    <div className="grid md:grid-cols-2 gap-6">
                      <div>
                        <h3 className="text-lg font-semibold text-white mb-2">Plan Details</h3>
                        <div className="space-y-2 text-gray-300">
                          <p>
                            <span className="text-gray-400">Plan:</span> Professional
                          </p>
                          <p>
                            <span className="text-gray-400">Price:</span> ₹4,999/month
                          </p>
                          <p>
                            <span className="text-gray-400">Next billing:</span> February 15, 2024
                          </p>
                          <p>
                            <span className="text-gray-400">Status:</span>{" "}
                            <Badge className="bg-green-500">Active</Badge>
                          </p>
                        </div>
                      </div>

                      <div>
                        <h3 className="text-lg font-semibold text-white mb-2">Usage This Month</h3>
                        <div className="space-y-2 text-gray-300">
                          <p>
                            <span className="text-gray-400">Case leads:</span> 23/50
                          </p>
                          <p>
                            <span className="text-gray-400">Profile views:</span> 1,247
                          </p>
                          <p>
                            <span className="text-gray-400">Client inquiries:</span> 18
                          </p>
                        </div>
                      </div>
                    </div>

                    <div className="flex gap-4 pt-4">
                      <Button className="bg-blue-600 hover:bg-blue-700">
                        <CreditCard className="w-4 h-4 mr-2" />
                        Update Payment Method
                      </Button>
                      <Button
                        variant="outline"
                        className="border-gray-600 text-gray-300 hover:bg-gray-800 bg-transparent"
                      >
                        <Calendar className="w-4 h-4 mr-2" />
                        Change Plan
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              </TabsContent>

              <TabsContent value="history">
                <Card className="bg-gray-900/50 backdrop-blur-sm border-gray-700">
                  <CardHeader>
                    <CardTitle className="text-white">Billing History</CardTitle>
                    <CardDescription className="text-gray-400">Your recent billing transactions</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-4">
                      {billingHistory.map((bill) => (
                        <div
                          key={bill.id}
                          className="flex items-center justify-between p-4 bg-gray-800/50 rounded-lg border border-gray-700"
                        >
                          <div>
                            <p className="text-white font-medium">{bill.plan} Plan</p>
                            <p className="text-gray-400 text-sm">{bill.date}</p>
                          </div>
                          <div className="text-right">
                            <p className="text-white font-medium">{bill.amount}</p>
                            <div className="flex items-center gap-2">
                              <Badge className="bg-green-500">{bill.status}</Badge>
                              <Button size="sm" variant="ghost" className="text-gray-400 hover:text-white">
                                <Download className="w-4 h-4 mr-1" />
                                Invoice
                              </Button>
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>
                  </CardContent>
                </Card>
              </TabsContent>
            </Tabs>
          </motion.div>
        </div>
      </PageContainer>
    </>
  )
}

export default withLawyerAuth(ProBillingPage)
