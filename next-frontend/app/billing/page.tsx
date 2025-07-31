"use client"

import { useState } from "react"
import { motion } from "framer-motion"
import { AnimatedBackground } from "@/components/animated-background"
import { CursorLight } from "@/components/cursor-light"
import { Navigation } from "@/components/navigation"
import { GlassCard } from "@/components/glass-card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { CreditCard, Check, Star, Crown, Zap } from "lucide-react"

const plans = [
  {
    name: "Basic",
    price: "₹999",
    period: "month",
    description: "Perfect for individual practitioners",
    features: [
      "Up to 10 case analyses per month",
      "Basic legal research tools",
      "Email support",
      "Standard templates",
      "Mobile app access",
    ],
    popular: false,
    icon: <Star className="w-6 h-6" />,
  },
  {
    name: "Professional",
    price: "₹2,499",
    period: "month",
    description: "Ideal for growing law firms",
    features: [
      "Unlimited case analyses",
      "Advanced legal research",
      "Priority support",
      "Custom templates",
      "Team collaboration",
      "Analytics dashboard",
      "API access",
    ],
    popular: true,
    icon: <Crown className="w-6 h-6" />,
  },
  {
    name: "Enterprise",
    price: "₹4,999",
    period: "month",
    description: "For large firms and organizations",
    features: [
      "Everything in Professional",
      "White-label solution",
      "Dedicated account manager",
      "Custom integrations",
      "Advanced security",
      "Training sessions",
      "24/7 phone support",
    ],
    popular: false,
    icon: <Zap className="w-6 h-6" />,
  },
]

export default function BillingPage() {
  const [currentPlan, setCurrentPlan] = useState("Professional")
  const [billingCycle, setBillingCycle] = useState("monthly")

  return (
    <div className="min-h-screen relative overflow-hidden">
      <AnimatedBackground />
      <CursorLight />
      <Navigation />

      <main className="pt-20 px-4">
        <div className="max-w-6xl mx-auto">
          <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="mb-8 text-center">
            <h1 className="text-4xl font-bold text-charcoal dark:text-off-white mb-4">Subscription & Billing</h1>
            <p className="text-charcoal/70 dark:text-off-white/70 text-lg">
              Choose the perfect plan for your legal practice
            </p>
          </motion.div>

          {/* Current Subscription */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="mb-8"
          >
            <GlassCard className="p-6">
              <div className="flex justify-between items-center">
                <div>
                  <h2 className="text-2xl font-semibold text-charcoal dark:text-off-white mb-2">
                    Current Subscription
                  </h2>
                  <div className="flex items-center gap-3">
                    <Badge className="bg-prestige-blue/20 dark:bg-electric-blue/20 text-prestige-blue dark:text-electric-blue border-prestige-blue/30 dark:border-electric-blue/30">
                      {currentPlan}
                    </Badge>
                    <span className="text-charcoal/70 dark:text-off-white/70">Next billing: January 15, 2024</span>
                  </div>
                </div>
                <div className="text-right">
                  <div className="text-3xl font-bold text-charcoal dark:text-off-white">₹2,499</div>
                  <div className="text-charcoal/70 dark:text-off-white/70">per month</div>
                </div>
              </div>
            </GlassCard>
          </motion.div>

          {/* Billing Toggle */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            className="mb-8 flex justify-center"
          >
            <div className="bg-white/10 backdrop-blur-md rounded-full p-1 border border-white/20">
              <div className="flex">
                <button
                  onClick={() => setBillingCycle("monthly")}
                  className={`px-6 py-2 rounded-full transition-all duration-300 ${
                    billingCycle === "monthly"
                      ? "bg-prestige-blue dark:bg-electric-blue text-white"
                      : "text-charcoal dark:text-off-white hover:bg-white/10"
                  }`}
                >
                  Monthly
                </button>
                <button
                  onClick={() => setBillingCycle("yearly")}
                  className={`px-6 py-2 rounded-full transition-all duration-300 ${
                    billingCycle === "yearly"
                      ? "bg-prestige-blue dark:bg-electric-blue text-white"
                      : "text-charcoal dark:text-off-white hover:bg-white/10"
                  }`}
                >
                  Yearly (Save 20%)
                </button>
              </div>
            </div>
          </motion.div>

          {/* Plans */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.3 }}
            className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8"
          >
            {plans.map((plan, index) => (
              <motion.div
                key={plan.name}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.1 * index }}
                className="relative"
              >
                {plan.popular && (
                  <div className="absolute -top-3 left-1/2 -translate-x-1/2 z-10">
                    <Badge className="bg-prestige-blue dark:bg-electric-blue text-white border-0">Most Popular</Badge>
                  </div>
                )}

                <GlassCard
                  className={`p-6 h-full ${
                    plan.popular ? "ring-2 ring-prestige-blue dark:ring-electric-blue" : ""
                  } ${currentPlan === plan.name ? "bg-white/20" : ""}`}
                >
                  <div className="text-center mb-6">
                    <div className="flex justify-center mb-3 text-prestige-blue dark:text-electric-blue">
                      {plan.icon}
                    </div>
                    <h3 className="text-2xl font-bold text-charcoal dark:text-off-white mb-2">{plan.name}</h3>
                    <p className="text-charcoal/70 dark:text-off-white/70 text-sm mb-4">{plan.description}</p>
                    <div className="text-4xl font-bold text-charcoal dark:text-off-white">
                      {billingCycle === "yearly"
                        ? `₹${Math.floor(Number.parseInt(plan.price.replace("₹", "")) * 0.8)}`
                        : plan.price}
                    </div>
                    <div className="text-charcoal/70 dark:text-off-white/70">
                      per {billingCycle === "yearly" ? "month, billed yearly" : "month"}
                    </div>
                  </div>

                  <ul className="space-y-3 mb-6">
                    {plan.features.map((feature, idx) => (
                      <li key={idx} className="flex items-center gap-2 text-sm">
                        <Check className="w-4 h-4 text-green-500 flex-shrink-0" />
                        <span className="text-charcoal dark:text-off-white">{feature}</span>
                      </li>
                    ))}
                  </ul>

                  <Button
                    className={`w-full ${
                      currentPlan === plan.name
                        ? "bg-gray-500 hover:bg-gray-600 cursor-not-allowed"
                        : plan.popular
                          ? "bg-prestige-blue dark:bg-electric-blue hover:bg-prestige-blue/90 dark:hover:bg-electric-blue/90"
                          : "bg-white/10 hover:bg-white/20 text-charcoal dark:text-off-white border border-white/20"
                    }`}
                    disabled={currentPlan === plan.name}
                  >
                    {currentPlan === plan.name ? "Current Plan" : "Upgrade"}
                  </Button>
                </GlassCard>
              </motion.div>
            ))}
          </motion.div>

          {/* Payment Method */}
          <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.4 }}>
            <GlassCard className="p-6">
              <h2 className="text-2xl font-semibold text-charcoal dark:text-off-white mb-6 flex items-center gap-2">
                <CreditCard className="w-5 h-5" />
                Payment Method
              </h2>

              <div className="flex items-center justify-between p-4 bg-white/10 rounded-lg border border-white/20">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-6 bg-gradient-to-r from-blue-500 to-purple-500 rounded"></div>
                  <div>
                    <div className="text-charcoal dark:text-off-white font-medium">•••• •••• •••• 4242</div>
                    <div className="text-charcoal/70 dark:text-off-white/70 text-sm">Expires 12/26</div>
                  </div>
                </div>
                <Button variant="outline" size="sm" className="border-white/20 hover:bg-white/10 bg-transparent">
                  Update
                </Button>
              </div>
            </GlassCard>
          </motion.div>
        </div>
      </main>
    </div>
  )
}
