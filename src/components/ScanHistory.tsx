import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion } from 'framer-motion'
import { History, Calendar, Search, Filter, ArrowUpRight, Download, MoreVertical, Loader2 } from 'lucide-react'
import { GlassCard } from './ui/GlassCard'
import { cn } from '../lib/utils'
import { db, auth } from '../lib/firebase'
import { collection, query, where, orderBy, getDocs } from 'firebase/firestore'

export function ScanHistory() {
  const navigate = useNavigate()
  const [loading, setLoading] = useState(true)
  const [indexError, setIndexError] = useState<string | null>(null)
  const [scans, setScans] = useState<any[]>([])

  useEffect(() => {
    const fetchScans = async () => {
      if (!auth.currentUser) return
      
      try {
        setIndexError(null)
        const q = query(
          collection(db, 'scans'),
          where('userId', '==', auth.currentUser.uid),
          orderBy('timestamp', 'desc')
        )
        const querySnapshot = await getDocs(q)
        const fetchedScans = querySnapshot.docs.map(doc => ({
          id: doc.id,
          ...doc.data(),
          date: doc.data().timestamp?.toDate().toLocaleDateString('en-US', {
            month: 'short',
            day: '2-digit',
            year: 'numeric'
          }) || 'Recently'
        }))
        setScans(fetchedScans)
      } catch (err: any) {
        console.error('Error fetching scans:', err)
        if (err.message?.includes('index')) {
          setIndexError('The scan history requires a specialized database index. Please check your developer console for the creation link.')
        }
      } finally {
        setLoading(false)
      }
    }

    fetchScans()
  }, [])

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]">
        <Loader2 className="animate-spin text-primary" size={48} />
      </div>
    )
  }

  if (indexError) {
    return (
      <div className="max-w-2xl mx-auto pt-20">
        <GlassCard className="p-12 text-center border-amber-500/20 bg-amber-500/5">
          <div className="p-4 bg-amber-500/20 text-amber-500 rounded-3xl w-fit mx-auto mb-6">
            <History size={32} />
          </div>
          <h2 className="text-2xl font-bold italic mb-4">History Unavailable</h2>
          <p className="text-white/60 text-sm leading-relaxed mb-8">
            {indexError}
          </p>
          <button 
            onClick={() => window.location.reload()}
            className="px-8 py-4 bg-amber-500 text-black font-bold rounded-2xl hover:scale-105 transition-transform uppercase tracking-widest text-[10px]"
          >
            Reload History
          </button>
        </GlassCard>
      </div>
    )
  }

  return (
    <div className="max-w-6xl mx-auto space-y-12 pb-24">
      <div className="flex flex-col md:flex-row md:items-end justify-between gap-6">
        <div>
          <h1 className="text-5xl font-bold tracking-tighter italic mb-2">Scan <span className="text-primary not-italic font-black">HISTORY</span></h1>
          <p className="text-white/40 text-sm">Review your past field diagnostics and health trends.</p>
        </div>
        <div className="flex items-center gap-3">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-white/20" size={16} />
            <input 
              type="text" 
              placeholder="Search crops..."
              className="bg-white/5 border border-white/10 rounded-xl py-2 pl-10 pr-4 text-xs outline-none focus:border-primary/50 transition-all"
            />
          </div>
          <button className="p-2.5 bg-white/5 border border-white/10 rounded-xl text-white/40 hover:text-white transition-all">
            <Filter size={18} />
          </button>
        </div>
      </div>

      <div className="space-y-4">
        {scans.length > 0 ? scans.map((scan, idx) => (
          <motion.div
            key={scan.id}
            initial={{ opacity: 0, x: -20 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: idx * 0.1 }}
          >
            <GlassCard className="p-2 border-white/5 bg-white/5 hover:border-primary/20 transition-all group cursor-pointer">
              <div className="flex items-center gap-6 p-4">
                <div className="w-12 h-12 rounded-xl bg-white/5 flex items-center justify-center text-primary group-hover:scale-110 transition-transform">
                  <History size={24} />
                </div>
                
                <div className="flex-1 grid grid-cols-2 md:grid-cols-4 gap-6">
                  <div>
                    <p className="text-[10px] font-bold text-white/20 uppercase tracking-widest mb-1">Crop</p>
                    <p className="text-sm font-bold">{scan.cropName || 'Maize'}</p>
                  </div>
                  <div>
                    <p className="text-[10px] font-bold text-white/20 uppercase tracking-widest mb-1">Diagnosis</p>
                    <p className={cn(
                      "text-sm font-bold",
                      scan.disease === 'Healthy' ? 'text-primary' : 'text-amber-400'
                    )}>{scan.disease}</p>
                  </div>
                  <div className="hidden md:block">
                    <p className="text-[10px] font-bold text-white/20 uppercase tracking-widest mb-1">Date</p>
                    <div className="flex items-center gap-2 text-sm text-white/60 font-medium">
                      <Calendar size={14} /> {scan.date}
                    </div>
                  </div>
                  <div className="hidden md:block">
                    <p className="text-[10px] font-bold text-white/20 uppercase tracking-widest mb-1">Confidence</p>
                    <p className="text-sm font-mono">{scan.confidence?.toFixed(1) || '0.0'}%</p>
                  </div>
                </div>

                <div className="flex items-center gap-3">
                  <button className="p-2 rounded-lg hover:bg-white/5 text-white/20 hover:text-white transition-all">
                    <Download size={18} />
                  </button>
                  <div className="h-6 w-px bg-white/10" />
                  <button 
                    onClick={() => navigate(`/report/${scan.id}`)}
                    className="flex items-center gap-2 px-4 py-2 bg-primary/10 text-primary text-[10px] font-bold uppercase tracking-widest rounded-lg group-hover:bg-primary group-hover:text-black transition-all"
                  >
                    View Report <ArrowUpRight size={14} />
                  </button>
                </div>
              </div>
            </GlassCard>
          </motion.div>
        )) : (
          <p className="text-center py-24 text-white/20 italic">No scan history found. Your crop diagnostics will appear here.</p>
        )}
      </div>

      {scans.length > 5 && (
        <div className="flex justify-center pt-8">
          <button className="px-8 py-3 rounded-2xl border border-white/10 text-white/40 hover:text-white hover:border-white/20 transition-all font-bold text-xs uppercase tracking-widest">
            Load More History
          </button>
        </div>
      )}
    </div>
  )
}
