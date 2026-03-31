import { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Sprout, Scan, BarChart3, User, Menu, X, Zap, Leaf, Activity, History as HistoryIcon, BookOpen, ChevronDown, Lock } from 'lucide-react'
import { cn } from '../lib/utils'

interface NavbarProps {
  currentView: 'home' | 'scan' | 'insights' | 'dashboard' | 'profile' | 'history' | 'learning'
  setView: (view: 'home' | 'scan' | 'insights' | 'dashboard' | 'profile' | 'history' | 'learning') => void
  theme: 'bitget' | 'greenfamily'
  setTheme: (theme: 'bitget' | 'greenfamily') => void
}

export function Navbar({ currentView, setView, theme, setTheme }: NavbarProps) {
  const [scrolled, setScrolled] = useState(false)
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)

  useEffect(() => {
    const handleScroll = () => setScrolled(window.scrollY > 20)
    window.addEventListener('scroll', handleScroll)
    return () => window.removeEventListener('scroll', handleScroll)
  }, [])

  const navLinks: { name: string, icon: React.ReactNode, id: 'home' | 'scan' | 'insights' | 'dashboard' }[] = [
    { name: 'Home', icon: <Sprout size={18} />, id: 'home' },
    { name: 'Scan', icon: <Scan size={18} />, id: 'scan' },
    { name: 'Insights', icon: <BarChart3 size={18} />, id: 'insights' },
    { name: 'Dashboard', icon: <Activity size={18} />, id: 'dashboard' },
  ]

  const userLinks: { name: string, icon: React.ReactNode, id: 'profile' | 'history' | 'learning' }[] = [
    { name: 'Profile Settings', icon: <User size={16} />, id: 'profile' },
    { name: 'Scan History', icon: <HistoryIcon size={16} />, id: 'history' },
    { name: 'Learning Center', icon: <BookOpen size={16} />, id: 'learning' },
  ]

  const toggleTheme = () => {
    const newTheme = theme === 'bitget' ? 'greenfamily' : 'bitget'
    setTheme(newTheme)
    
    const root = window.document.documentElement
    root.classList.remove('dark', 'theme-green')
    if (newTheme === 'bitget') {
      root.classList.add('dark')
    } else {
      root.classList.add('theme-green')
    }
  }

  return (
    <nav 
      className={cn(
        "fixed top-0 left-0 right-0 z-[100] transition-all duration-500 border-b",
        scrolled 
          ? "py-4 bg-black/40 backdrop-blur-xl border-white/10" 
          : "py-8 bg-transparent border-transparent"
      )}
    >
      <div className="container mx-auto px-6 flex items-center justify-between">
        <div className="flex items-center gap-4 cursor-pointer group" onClick={() => setView('home')}>
          <div className="relative w-10 h-10 flex items-center justify-center rounded-2xl bg-white/5 border border-white/10 group-hover:border-white/20 transition-all overflow-hidden">
            <img src="/logo.png?v=1" alt="VERD Logo" className="w-6 h-6 object-contain relative z-10 opacity-80 group-hover:opacity-100 transition-opacity" />
          </div>
          <div className="hidden md:block">
            <span className="text-xl font-bold tracking-tighter italic block leading-none">VERD</span>
            <span className="text-[8px] font-black tracking-[0.3em] text-white/20 uppercase">Agronomy Hub</span>
          </div>
        </div>

        {/* Desktop Nav */}
        <div className="hidden md:flex items-center gap-8">
          <div className="flex items-center gap-1 bg-white/5 p-1 rounded-full border border-white/10">
            {navLinks.map((link) => (
              <button 
                key={link.id} 
                onClick={() => setView(link.id)}
                className={cn(
                  "flex items-center gap-2 px-4 py-2 rounded-full text-sm font-medium transition-all duration-300",
                  currentView === link.id 
                    ? "bg-primary text-white shadow-lg" 
                    : "text-white/40 hover:text-white"
                )}
              >
                {link.icon}
                {link.name}
              </button>
            ))}
          </div>

          <div className="flex items-center gap-4">
            <button 
              onClick={toggleTheme}
              className="p-3 rounded-full bg-white/5 border border-white/10 text-white/40 hover:text-white transition-all hover:border-primary/50 group/theme"
              title="Switch Theme"
            >
              {theme === 'bitget' ? <Zap size={18} className="group-hover/theme:text-primary transition-colors" /> : <Leaf size={18} className="group-hover/theme:text-emerald-500 transition-colors" />}
            </button>
            
            <div className="relative group/user">
              <button className={cn(
                "flex items-center gap-2 px-6 py-2.5 bg-white/5 border border-white/10 rounded-full text-sm font-bold hover:bg-white/10 transition-all",
                ['profile', 'history', 'learning'].includes(currentView) && "border-primary/50 text-primary/80"
              )}>
                <User size={16} />
                Welcome Alex
                <ChevronDown size={14} className="opacity-40 group-hover/user:rotate-180 transition-transform" />
              </button>
              
              <div className="absolute top-full right-0 mt-3 w-64 bg-black/80 backdrop-blur-3xl border border-white/10 rounded-3xl p-2 opacity-0 invisible group-hover/user:opacity-100 group-hover/user:visible transition-all -translate-y-2 group-hover/user:translate-y-0 shadow-2xl">
                {userLinks.map((link) => (
                  <button 
                    key={link.id} 
                    onClick={() => setView(link.id)}
                    className={cn(
                      "flex items-center gap-3 w-full text-left px-4 py-3 rounded-2xl text-xs font-bold transition-all",
                      currentView === link.id ? "bg-primary text-black" : "text-white/40 hover:bg-white/5 hover:text-white"
                    )}
                  >
                    {link.icon}
                    {link.name}
                  </button>
                ))}
                <hr className="border-white/5 my-2 mx-4" />
                <button className="flex items-center gap-3 w-full text-left px-4 py-3 rounded-2xl text-xs font-bold text-red-400 hover:bg-red-400/10 transition-all">
                  Sign Out
                </button>
              </div>
            </div>
          </div>
        </div>

        {/* Mobile Toggle */}
        <button 
          className="md:hidden p-2 text-white/60 hover:text-white"
          onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
        >
          {mobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
        </button>
      </div>

      {/* Mobile Menu */}
      <AnimatePresence>
        {mobileMenuOpen && (
          <motion.div
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="absolute top-full left-0 right-0 p-6 bg-black/90 backdrop-blur-3xl border-b border-white/10 md:hidden"
          >
            <div className="flex flex-col gap-6">
              {navLinks.map((link) => (
                <button 
                  key={link.id} 
                  onClick={() => {
                    setView(link.id)
                    setMobileMenuOpen(false)
                  }}
                  className={cn(
                    "flex items-center gap-4 text-lg font-medium transition-colors",
                    currentView === link.id ? "text-primary" : "text-white/60"
                  )}
                >
                  {link.icon}
                  {link.name}
                </button>
              ))}
              <hr className="border-white/5" />
              <div className="flex flex-col gap-4">
                <p className="text-[10px] font-bold text-white/20 uppercase tracking-[0.3em] px-2">Account Management</p>
                {userLinks.map((link) => (
                  <button 
                    key={link.id} 
                    onClick={() => {
                      setView(link.id)
                      setMobileMenuOpen(false)
                    }}
                    className={cn(
                      "flex items-center gap-4 text-base font-medium transition-colors px-2",
                      currentView === link.id ? "text-primary" : "text-white/40"
                    )}
                  >
                    {link.icon}
                    {link.name}
                  </button>
                ))}
              </div>
              <hr className="border-white/5" />
              <div className="flex items-center justify-between">
                <button 
                  onClick={toggleTheme}
                  className="flex items-center gap-3 text-white/60 text-sm"
                >
                  {theme === 'bitget' ? <Zap size={18} /> : <Leaf size={18} />}
                  Switch Theme
                </button>
                <button className="text-red-400 text-sm font-bold">Sign Out</button>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </nav>
  )
}
