"use client"

import type React from "react"

import { useRef, useEffect, useState } from "react"
import { motion } from "framer-motion"
import { GlassCard } from "@/components/glass-card"
import { Badge } from "@/components/ui/badge"
import { X } from "lucide-react"

interface NebulaNode {
  id: string
  title: string
  description: string
  x: number
  y: number
  type: "incident" | "ipc" | "defense" | "punishment"
  connections: string[]
}

interface AnalysisNebulaProps {
  data: {
    incident: string
    ipcSections: Array<{ id: string; title: string; description: string }>
    defenses: Array<{ id: string; title: string; description: string }>
    punishments: Array<{ id: string; title: string; description: string }>
  }
}

export function AnalysisNebula({ data }: AnalysisNebulaProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const [selectedNode, setSelectedNode] = useState<NebulaNode | null>(null)
  const [nodes, setNodes] = useState<NebulaNode[]>([])
  const [isDragging, setIsDragging] = useState(false)
  const [dragOffset, setDragOffset] = useState({ x: 0, y: 0 })

  useEffect(() => {
    // Create nodes from data
    const centerX = 400
    const centerY = 300

    const newNodes: NebulaNode[] = [
      {
        id: "incident",
        title: "Your Incident",
        description: data.incident,
        x: centerX,
        y: centerY,
        type: "incident",
        connections: data.ipcSections.map((s) => s.id),
      },
      ...data.ipcSections.map((section, index) => ({
        id: section.id,
        title: section.title,
        description: section.description,
        x: centerX + Math.cos((index * 2 * Math.PI) / data.ipcSections.length) * 150,
        y: centerY + Math.sin((index * 2 * Math.PI) / data.ipcSections.length) * 150,
        type: "ipc" as const,
        connections: [...data.defenses.map((d) => d.id), ...data.punishments.map((p) => p.id)],
      })),
      ...data.defenses.map((defense, index) => ({
        id: defense.id,
        title: defense.title,
        description: defense.description,
        x: centerX - 200 + index * 100,
        y: centerY + 200,
        type: "defense" as const,
        connections: [],
      })),
      ...data.punishments.map((punishment, index) => ({
        id: punishment.id,
        title: punishment.title,
        description: punishment.description,
        x: centerX + 100 + index * 100,
        y: centerY + 200,
        type: "punishment" as const,
        connections: [],
      })),
    ]

    setNodes(newNodes)
  }, [data])

  useEffect(() => {
    const canvas = canvasRef.current
    if (!canvas) return

    const ctx = canvas.getContext("2d")
    if (!ctx) return

    const animate = () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height)

      // Draw connections
      nodes.forEach((node) => {
        node.connections.forEach((connectionId) => {
          const connectedNode = nodes.find((n) => n.id === connectionId)
          if (connectedNode) {
            ctx.strokeStyle = "rgba(0, 82, 204, 0.3)"
            ctx.lineWidth = 2
            ctx.beginPath()
            ctx.moveTo(node.x, node.y)
            ctx.lineTo(connectedNode.x, connectedNode.y)
            ctx.stroke()
          }
        })
      })

      // Draw nodes
      nodes.forEach((node) => {
        const radius = node.type === "incident" ? 30 : 20
        const color = {
          incident: "#0052CC",
          ipc: "#33A1FF",
          defense: "#10B981",
          punishment: "#EF4444",
        }[node.type]

        // Pulsing effect for incident node
        const pulseRadius = node.type === "incident" ? radius + Math.sin(Date.now() * 0.003) * 5 : radius

        ctx.fillStyle = color
        ctx.beginPath()
        ctx.arc(node.x, node.y, pulseRadius, 0, 2 * Math.PI)
        ctx.fill()

        // Node border
        ctx.strokeStyle = "rgba(255, 255, 255, 0.5)"
        ctx.lineWidth = 2
        ctx.stroke()

        // Node label
        ctx.fillStyle = "white"
        ctx.font = "12px Inter"
        ctx.textAlign = "center"
        ctx.fillText(node.title.substring(0, 15) + "...", node.x, node.y + 5)
      })

      requestAnimationFrame(animate)
    }

    animate()
  }, [nodes])

  const handleCanvasClick = (e: React.MouseEvent<HTMLCanvasElement>) => {
    const canvas = canvasRef.current
    if (!canvas) return

    const rect = canvas.getBoundingClientRect()
    const x = e.clientX - rect.left
    const y = e.clientY - rect.top

    const clickedNode = nodes.find((node) => {
      const distance = Math.sqrt((x - node.x) ** 2 + (y - node.y) ** 2)
      return distance <= (node.type === "incident" ? 30 : 20)
    })

    if (clickedNode) {
      setSelectedNode(clickedNode)
    }
  }

  const handleMouseDown = (e: React.MouseEvent<HTMLCanvasElement>) => {
    setIsDragging(true)
    const rect = canvasRef.current?.getBoundingClientRect()
    if (rect) {
      setDragOffset({
        x: e.clientX - rect.left,
        y: e.clientY - rect.top,
      })
    }
  }

  const handleMouseMove = (e: React.MouseEvent<HTMLCanvasElement>) => {
    if (!isDragging) return

    const rect = canvasRef.current?.getBoundingClientRect()
    if (rect) {
      const deltaX = e.clientX - rect.left - dragOffset.x
      const deltaY = e.clientY - rect.top - dragOffset.y

      setNodes((prevNodes) =>
        prevNodes.map((node) => ({
          ...node,
          x: node.x + deltaX * 0.1,
          y: node.y + deltaY * 0.1,
        })),
      )

      setDragOffset({
        x: e.clientX - rect.left,
        y: e.clientY - rect.top,
      })
    }
  }

  const handleMouseUp = () => {
    setIsDragging(false)
  }

  return (
    <div className="relative">
      <motion.div initial={{ opacity: 0, scale: 0.9 }} animate={{ opacity: 1, scale: 1 }} className="mb-6">
        <GlassCard className="p-6">
          <h2 className="text-2xl font-bold text-charcoal dark:text-off-white mb-4">Analysis Nebula</h2>
          <p className="text-charcoal/70 dark:text-off-white/70 mb-4">
            Explore your case analysis as an interactive constellation. Click and drag to navigate.
          </p>

          <div className="relative">
            <canvas
              ref={canvasRef}
              width={800}
              height={600}
              className="w-full h-auto bg-black/20 rounded-lg cursor-grab active:cursor-grabbing"
              onClick={handleCanvasClick}
              onMouseDown={handleMouseDown}
              onMouseMove={handleMouseMove}
              onMouseUp={handleMouseUp}
              onMouseLeave={handleMouseUp}
            />

            <div className="absolute top-4 left-4 flex gap-2">
              <Badge className="bg-blue-500/20 text-blue-400 border-blue-500/30">Incident</Badge>
              <Badge className="bg-cyan-500/20 text-cyan-400 border-cyan-500/30">IPC Sections</Badge>
              <Badge className="bg-green-500/20 text-green-400 border-green-500/30">Defenses</Badge>
              <Badge className="bg-red-500/20 text-red-400 border-red-500/30">Punishments</Badge>
            </div>
          </div>
        </GlassCard>
      </motion.div>

      {/* Node Details Sidebar */}
      {selectedNode && (
        <motion.div
          initial={{ opacity: 0, x: 300 }}
          animate={{ opacity: 1, x: 0 }}
          exit={{ opacity: 0, x: 300 }}
          className="fixed right-4 top-1/2 -translate-y-1/2 w-80 z-50"
        >
          <GlassCard className="p-6">
            <div className="flex justify-between items-start mb-4">
              <h3 className="text-xl font-semibold text-charcoal dark:text-off-white">{selectedNode.title}</h3>
              <button
                onClick={() => setSelectedNode(null)}
                className="text-charcoal/60 dark:text-off-white/60 hover:text-charcoal dark:hover:text-off-white"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <Badge
              className={`mb-4 ${
                selectedNode.type === "incident"
                  ? "bg-blue-500/20 text-blue-400 border-blue-500/30"
                  : selectedNode.type === "ipc"
                    ? "bg-cyan-500/20 text-cyan-400 border-cyan-500/30"
                    : selectedNode.type === "defense"
                      ? "bg-green-500/20 text-green-400 border-green-500/30"
                      : "bg-red-500/20 text-red-400 border-red-500/30"
              }`}
            >
              {selectedNode.type.toUpperCase()}
            </Badge>

            <p className="text-charcoal/70 dark:text-off-white/70 leading-relaxed">{selectedNode.description}</p>
          </GlassCard>
        </motion.div>
      )}
    </div>
  )
}
