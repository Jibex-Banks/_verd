import React from 'react'
import { AlertTriangle, CheckCircle2, Zap, Sprout, ShieldCheck, MapPin } from 'lucide-react'
import { cn } from '../../lib/utils'

interface ResultShareCardProps {
  cropName: string
  disease: string
  confidence: number
  recommendation: string
  theme: 'bitget' | 'greenfamily'
  location?: string
  date?: string
}

export const ResultShareCard = React.forwardRef<HTMLDivElement, ResultShareCardProps>(({ 
  cropName, 
  disease, 
  confidence, 
  recommendation, 
  theme,
  location = "Savannah Belt Region",
  date = new Date().toLocaleDateString()
}, ref) => {
  const isBitget = theme === 'bitget'
  
  return (
    <div 
      ref={ref}
      className={cn(
        "w-[600px] aspect-[4/5] p-12 flex flex-col relative overflow-hidden text-white font-sans",
        isBitget ? "bg-black" : "bg-[#050b09]"
      )}
    >
      {/* Dynamic Background Patterns */}
      <div className="absolute inset-0 z-0">
        <div className={cn(
          "absolute top-0 right-0 w-[400px] h-[400px] rounded-full blur-[100px] opacity-20",
          isBitget ? "bg-primary" : "bg-emerald-500"
        )} />
        <div className="absolute bottom-0 left-0 w-[300px] h-[300px] bg-white/5 rounded-full blur-[80px] opacity-10" />
      </div>

      {/* Decorative Neural Grid (Simulated) */}
      <div className="absolute inset-0 opacity-[0.03] pointer-events-none z-0" style={{ backgroundImage: 'radial-gradient(circle, #fff 1px, transparent 1px)', backgroundSize: '30px 30px' }} />

      <div className="relative z-10 flex flex-col h-full">
        {/* Header Branding */}
        <div className="flex items-center justify-between mb-12">
          <div className="flex items-center gap-3">
            <div className="w-12 h-12 rounded-xl bg-white/5 border border-white/10 flex items-center justify-center">
              <Sprout size={24} className={isBitget ? "text-primary" : "text-emerald-500"} />
            </div>
            <div>
              <span className="text-xl font-bold tracking-tighter italic block leading-none">VERD</span>
              <span className="text-[8px] font-black tracking-[0.3em] text-white/20 uppercase">AGRI-NEURAL ENGINE</span>
            </div>
          </div>
          <div className="text-right">
            <p className="text-[8px] font-black text-white/20 uppercase tracking-[0.2em] mb-1">Authenticity ID</p>
            <p className="text-[10px] font-mono text-white/40">VN-#{Math.random().toString(36).substr(2, 6).toUpperCase()}</p>
          </div>
        </div>

        {/* Main Result Content */}
        <div className="flex-1">
          <div className="flex items-center gap-3 mb-4">
            <span className={cn(
              "px-3 py-1 rounded-full text-[10px] font-black tracking-widest uppercase border",
              isBitget ? "bg-primary/10 border-primary/20 text-primary" : "bg-emerald-500/10 border-emerald-500/20 text-emerald-500"
            )}>
              {cropName} DIAGNOSTIC
            </span>
            <div className="h-[1px] flex-1 bg-white/10" />
          </div>

          <h2 className="text-5xl font-bold tracking-tighter mb-8 leading-[1.1] italic">
            <span className="text-white/40 not-italic font-black block text-2xl uppercase mb-2">Finding:</span>
            {disease}
          </h2>

          <div className="grid grid-cols-2 gap-6 mb-10">
            <div className="p-6 rounded-3xl bg-white/5 border border-white/10">
              <p className="text-[8px] font-black text-white/40 uppercase tracking-widest mb-2">Confidence Level</p>
              <p className={cn("text-3xl font-mono font-bold tracking-tighter", isBitget ? "text-primary" : "text-emerald-500")}>
                {confidence.toFixed(1)}%
              </p>
            </div>
            <div className="p-6 rounded-3xl bg-white/5 border border-white/10">
              <p className="text-[8px] font-black text-white/40 uppercase tracking-widest mb-2">System Status</p>
              <div className="flex items-center gap-2 text-emerald-500">
                <ShieldCheck size={20} />
                <span className="text-sm font-bold uppercase tracking-widest">Verified</span>
              </div>
            </div>
          </div>

          <div className="p-8 rounded-[2rem] bg-white/5 border border-white/10 relative overflow-hidden">
            <div className="absolute top-0 right-0 p-4 opacity-5">
              <Zap size={100} />
            </div>
            <p className="text-[8px] font-black text-white/40 uppercase tracking-widest mb-4">Agronomist Recommendation</p>
            <p className="text-lg text-white/80 leading-relaxed italic">
              "{recommendation}"
            </p>
          </div>
        </div>

        {/* Footer Meta */}
        <div className="mt-12 pt-8 border-t border-white/5 flex items-center justify-between text-[10px] text-white/20 font-bold uppercase tracking-widest">
          <div className="flex items-center gap-4">
            <div className="flex items-center gap-2">
              <MapPin size={12} />
              {location}
            </div>
            <div className="w-1 h-1 bg-white/10 rounded-full" />
            <div>{date}</div>
          </div>
          <div className="flex items-center gap-2">
            <span className="opacity-50 italic">Powered by</span>
            <span className="text-white opacity-40">White Walkers</span>
          </div>
        </div>
      </div>
    </div>
  )
})

ResultShareCard.displayName = 'ResultShareCard'
