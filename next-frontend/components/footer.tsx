"use client"

import { motion } from "framer-motion"
import Link from "next/link"
import { Scale, Mail, Phone, MapPin, Twitter, Linkedin, Github, ArrowRight } from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Card } from "@/components/ui/card"

export function Footer() {
  const currentYear = new Date().getFullYear()

  const footerLinks = {
    Platform: [
      { name: "Incident Analyzer", href: "/analyzer" },
      { name: "Document Summarizer", href: "/summarizer" },
      { name: "Case Builder", href: "/case-builder" },
      { name: "Find Lawyers", href: "/find-lawyer" },
    ],
    Resources: [
      { name: "Legal Topics", href: "/explore" },
      { name: "Knowledge Base", href: "/knowledge" },
      { name: "Case Studies", href: "/case-studies" },
      { name: "Legal Updates", href: "/updates" },
    ],
    Company: [
      { name: "About Us", href: "/about" },
      { name: "Privacy Policy", href: "/privacy" },
      { name: "Terms of Service", href: "/terms" },
      { name: "Contact", href: "/contact" },
    ],
    Professional: [
      { name: "For Lawyers", href: "/pro/dashboard" },
      { name: "Pro Features", href: "/pro/features" },
      { name: "Pricing", href: "/pricing" },
      { name: "API Access", href: "/api" },
    ],
  }

  const socialLinks = [
    { name: "Twitter", icon: <Twitter className="w-5 h-5" />, href: "#" },
    { name: "LinkedIn", icon: <Linkedin className="w-5 h-5" />, href: "#" },
    { name: "GitHub", icon: <Github className="w-5 h-5" />, href: "#" },
  ]

  return (
    <footer className="relative bg-gray-50 dark:bg-[#0D1B2A] border-t border-gray-200 dark:border-[#1B263B] overflow-hidden">
      {/* Background Elements */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <motion.div
          className="absolute top-0 left-1/4 w-96 h-96 bg-gradient-to-r from-[#007BFF]/5 to-[#00FFFF]/5 rounded-full blur-3xl"
          animate={{
            scale: [1, 1.2, 1],
            opacity: [0.3, 0.5, 0.3],
          }}
          transition={{
            duration: 15,
            repeat: Number.POSITIVE_INFINITY,
            ease: "easeInOut",
          }}
        />
      </div>

      <div className="relative z-10">
        {/* Newsletter Section */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
          className="py-16 px-6"
        >
          <div className="max-w-4xl mx-auto text-center">
            <Card className="p-8 bg-white/80 dark:bg-[#1B263B]/80 backdrop-blur-sm border-gray-200 dark:border-[#1B263B]">
              <h3 className="text-3xl font-bold text-gray-900 dark:text-[#E0E6F1] mb-4">
                Stay Updated with Legal Insights
              </h3>
              <p className="text-gray-600 dark:text-gray-300 mb-8 max-w-2xl mx-auto">
                Get the latest legal technology updates, case studies, and expert insights delivered to your inbox.
              </p>
              <div className="flex flex-col sm:flex-row gap-4 max-w-md mx-auto">
                <Input
                  type="email"
                  placeholder="Enter your email address"
                  className="flex-1 bg-white dark:bg-[#0D1B2A]/50 border-gray-300 dark:border-[#1B263B] focus:border-[#007BFF] dark:focus:border-[#00FFFF] dark:focus:glow-cyan"
                />
                <motion.div whileHover={{ scale: 1.05 }} whileTap={{ scale: 0.95 }}>
                  <Button className="bg-[#007BFF] hover:bg-[#0056b3] dark:bg-[#00FFFF] dark:hover:bg-[#00CCCC] dark:text-[#0D1B2A] text-white prestigious-hover dark:glow-cyan">
                    Subscribe
                    <ArrowRight className="w-4 h-4 ml-2" />
                  </Button>
                </motion.div>
              </div>
            </Card>
          </div>
        </motion.div>

        {/* Main Footer Content */}
        <div className="py-16 px-6">
          <div className="max-w-7xl mx-auto">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-6 gap-12">
              {/* Brand Section */}
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ duration: 0.6 }}
                className="lg:col-span-2"
              >
                <Link href="/" className="flex items-center gap-3 mb-6 group">
                  <motion.div
                    className="p-3 bg-gradient-to-r from-[#007BFF] to-[#00FFFF] dark:from-[#00FFFF] dark:to-[#007BFF] rounded-xl shadow-lg group-hover:shadow-xl transition-all duration-300"
                    whileHover={{ scale: 1.1, rotate: 5 }}
                  >
                    <Scale className="w-8 h-8 text-white" />
                  </motion.div>
                  <div>
                    <h3 className="text-2xl font-bold text-gray-900 dark:text-[#E0E6F1]">Juris-Lead</h3>
                    <p className="text-sm text-gray-600 dark:text-gray-300">Legal Clarity with AI</p>
                  </div>
                </Link>
                <p className="text-gray-600 dark:text-gray-300 mb-6 leading-relaxed">
                  Empowering individuals and legal professionals with AI-driven insights for better legal outcomes.
                  Making complex legal matters accessible to everyone.
                </p>
                <div className="space-y-3">
                  <div className="flex items-center gap-3 text-gray-600 dark:text-gray-300">
                    <Mail className="w-5 h-5 text-[#007BFF] dark:text-[#00FFFF]" />
                    <span>contact@juris-lead.com</span>
                  </div>
                  <div className="flex items-center gap-3 text-gray-600 dark:text-gray-300">
                    <Phone className="w-5 h-5 text-[#007BFF] dark:text-[#00FFFF]" />
                    <span>+91 (800) 123-4567</span>
                  </div>
                  <div className="flex items-center gap-3 text-gray-600 dark:text-gray-300">
                    <MapPin className="w-5 h-5 text-[#007BFF] dark:text-[#00FFFF]" />
                    <span>Mumbai, Maharashtra, India</span>
                  </div>
                </div>
              </motion.div>

              {/* Footer Links */}
              {Object.entries(footerLinks).map(([category, links], index) => (
                <motion.div
                  key={category}
                  initial={{ opacity: 0, y: 20 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.6, delay: 0.1 * (index + 1) }}
                >
                  <h4 className="text-lg font-semibold text-gray-900 dark:text-[#E0E6F1] mb-6">{category}</h4>
                  <ul className="space-y-3">
                    {links.map((link) => (
                      <li key={link.name}>
                        <Link
                          href={link.href}
                          className="text-gray-600 dark:text-gray-300 hover:text-[#007BFF] dark:hover:text-[#00FFFF] transition-colors duration-300 prestigious-hover"
                        >
                          {link.name}
                        </Link>
                      </li>
                    ))}
                  </ul>
                </motion.div>
              ))}
            </div>
          </div>
        </div>

        {/* Bottom Bar */}
        <motion.div
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="border-t border-gray-200 dark:border-[#1B263B] py-8 px-6"
        >
          <div className="max-w-7xl mx-auto flex flex-col md:flex-row justify-between items-center gap-6">
            <div className="text-center md:text-left">
              <p className="text-gray-600 dark:text-gray-300">© {currentYear} Juris-Lead. All rights reserved.</p>
              <p className="text-sm text-gray-500 dark:text-gray-400 mt-1">
                Built with ❤️ for the legal community in India
              </p>
            </div>

            {/* Social Links */}
            <div className="flex items-center gap-4">
              {socialLinks.map((social) => (
                <motion.a
                  key={social.name}
                  href={social.href}
                  className="p-3 bg-gray-100 dark:bg-[#1B263B] text-gray-600 dark:text-gray-300 hover:bg-[#007BFF] dark:hover:bg-[#00FFFF] hover:text-white dark:hover:text-[#0D1B2A] rounded-lg transition-all duration-300 prestigious-hover"
                  whileHover={{ scale: 1.1, y: -2 }}
                  whileTap={{ scale: 0.95 }}
                  aria-label={social.name}
                >
                  {social.icon}
                </motion.a>
              ))}
            </div>
          </div>
        </motion.div>
      </div>
    </footer>
  )
}
