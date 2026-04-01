import { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Sprout, Scan, BarChart3, User, Menu, X, Zap, Leaf, Activity, History as HistoryIcon, BookOpen, ChevronDown, Lock, LogOut } from 'lucide-react'
import { cn } from '../lib/utils'
import { NavLink, Link, useNavigate, useLocation } from 'react-router-dom'
import { auth, db } from '../lib/firebase'
import { doc, onSnapshot } from 'firebase/firestore'
import { signOut } from 'firebase/auth'

interface NavbarProps {
  theme: 'bitget' | 'greenfamily'
  setTheme: (theme: 'bitget' | 'greenfamily') => void
  showAuth: boolean
  setShowAuth: (show: boolean) => void
  setAuthMode: (mode: 'login' | 'signup') => void
}

export function Navbar({ theme, setTheme, setShowAuth, setAuthMode }: NavbarProps) {
  const navigate = useNavigate()
  const location = useLocation()
  const [scrolled, setScrolled] = useState(false)
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false)
  const [userName, setUserName] = useState<string | null>(null)

  useEffect(() => {
    const handleScroll = () => setScrolled(window.scrollY > 20)
    window.addEventListener('scroll', handleScroll)
    return () => window.removeEventListener('scroll', handleScroll)
  }, [])

  useEffect(() => {
    if (!auth.currentUser) {
      setUserName(null)
      return
    }

    const unsubscribe = onSnapshot(doc(db, 'users', auth.currentUser.uid), (doc) => {
      if (doc.exists()) {
        setUserName(doc.data().fullName || auth.currentUser?.displayName || 'User')
      } else {
        setUserName(auth.currentUser?.displayName || 'User')
      }
    })

    return () => unsubscribe()
  }, [auth.currentUser])

  const handleSignOut = async () => {
    try {
      await signOut(auth)
      navigate('/')
    } catch (err) {
      console.error('Error signing out:', err)
    }
  }

  const navLinks = [
    { name: 'Home', icon: <Sprout size={18} />, path: '/' },
    { name: 'Scan', icon: <Scan size={18} />, path: '/scan' },
    { name: 'Insights', icon: <BarChart3 size={18} />, path: '/insights' },
    { name: 'Dashboard', icon: <Activity size={18} />, path: '/dashboard' },
  ]

  const userLinks = [
    { name: 'Profile Settings', icon: <User size={16} />, path: '/profile' },
    { name: 'Scan History', icon: <HistoryIcon size={16} />, path: '/history' },
    { name: 'Learning Center', icon: <BookOpen size={16} />, path: '/learning' },
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
        <Link to="/" className="flex items-center gap-4 cursor-pointer group">
          <div className="relative w-14 h-14 flex items-center justify-center rounded-2xl bg-white/5 border border-white/10 group-hover:border-white/20 transition-all overflow-hidden">
            <img src="/logo.png?v=1" alt="VERD Logo" className="w-10 h-10 object-contain relative z-10 opacity-80 group-hover:opacity-100 transition-opacity" />
          </div>
          <div className="hidden md:block">
            <span className="text-xl font-bold tracking-tighter italic block leading-none">VERD</span>
            <span className="text-[8px] font-black tracking-[0.3em] text-white/20 uppercase">Agronomy Hub</span>
          </div>
        </Link>

        {/* Desktop Nav */}
        <div className="hidden md:flex items-center gap-8">
          <div className="flex items-center gap-1 bg-white/5 p-1 rounded-full border border-white/10">
            {navLinks.map((link) => (
              <NavLink 
                key={link.path} 
                to={link.path}
                className={({ isActive }) => cn(
                  "flex items-center gap-2 px-4 py-2 rounded-full text-sm font-medium transition-all duration-300",
                  isActive 
                    ? "bg-primary text-white shadow-lg" 
                    : "text-white/40 hover:text-white"
                )}
              >
                {link.icon}
                {link.name}
              </NavLink>
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
                ['/profile', '/history', '/learning'].includes(location.pathname) && "border-primary/50 text-primary/80"
              )}>
                <User size={16} />
                {userName ? `Welcome ${userName}` : 'Account'}
                <ChevronDown size={14} className="opacity-40 group-hover/user:rotate-180 transition-transform" />
              </button>
              
              <div className="absolute top-full right-0 mt-3 w-64 bg-black/80 backdrop-blur-3xl border border-white/10 rounded-3xl p-2 opacity-0 invisible group-hover/user:opacity-100 group-hover/user:visible transition-all -translate-y-2 group-hover/user:translate-y-0 shadow-2xl">
                {userLinks.map((link) => (
                  <NavLink 
                    key={link.path} 
                    to={link.path}
                    className={({ isActive }) => cn(
                      "flex items-center gap-3 w-full text-left px-4 py-3 rounded-2xl text-xs font-bold transition-all",
                      isActive ? "bg-primary text-black" : "text-white/40 hover:bg-white/5 hover:text-white"
                    )}
                  >
                    {link.icon}
                    {link.name}
                  </NavLink>
                ))}
                <hr className="border-white/5 my-2 mx-4" />
                <button 
                  onClick={handleSignOut}
                  className="flex items-center gap-3 w-full text-left px-4 py-3 rounded-2xl text-xs font-bold text-red-400 hover:bg-red-400/10 transition-all font-mono tracking-widest"
                >
                  <LogOut size={16} />
                  SIGN OUT
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

      {/* Mobile Menu Overlay */}
      <AnimatePresence>
        {mobileMenuOpen && (
          <motion.div
            initial={{ opacity: 0, x: '100%' }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: '100%' }}
            transition={{ type: "spring", damping: 25, stiffness: 200 }}
            className="fixed inset-0 z-[150] bg-black/95 backdrop-blur-2xl md:hidden flex flex-col"
          >
            <div className="flex items-center justify-between p-6 border-b border-white/10">
              <div className="flex items-center gap-4">
                <div className="w-10 h-10 rounded-xl bg-white/5 border border-white/10 flex items-center justify-center">
                  <img src="/logo.png?v=1" alt="Logo" className="w-6 h-6 opacity-80" />
                </div>
                <span className="text-xl font-bold italic tracking-tighter">VERD</span>
              </div>
              <button 
                onClick={() => setMobileMenuOpen(false)}
                className="p-2 text-white/60 hover:text-white bg-white/5 rounded-full border border-white/10"
              >
                <X size={24} />
              </button>
            </div>

            <div className="flex-1 overflow-y-auto p-6 flex flex-col gap-8">
              <div className="flex flex-col gap-4">
                <p className="text-[10px] font-bold text-white/20 uppercase tracking-[0.3em] px-2 mb-2">Main Navigation</p>
                {navLinks.map((link) => (
                  <NavLink 
                    key={link.path} 
                    to={link.path}
                    onClick={() => setMobileMenuOpen(false)}
                    className={({ isActive }) => cn(
                      "flex items-center gap-4 py-4 px-4 rounded-2xl text-xl font-medium transition-all",
                      isActive ? "bg-primary/10 text-primary border border-primary/20" : "text-white/60 hover:bg-white/5"
                    )}
                  >
                    {link.icon}
                    {link.name}
                  </NavLink>
                ))}
              </div>

              <div className="flex flex-col gap-4">
                <p className="text-[10px] font-bold text-white/20 uppercase tracking-[0.3em] px-2 mb-2">Account & Settings</p>
                <div className="grid grid-cols-1 gap-2">
                  {userLinks.map((link) => (
                    <NavLink 
                      key={link.path} 
                      to={link.path}
                      onClick={() => setMobileMenuOpen(false)}
                      className={({ isActive }) => cn(
                        "flex items-center gap-4 py-4 px-4 rounded-2xl text-base font-medium transition-all",
                        isActive ? "bg-primary/10 text-primary border border-primary/20" : "text-white/40 hover:bg-white/5"
                      )}
                    >
                      {link.icon}
                      {link.name}
                    </NavLink>
                  ))}
                </div>
              </div>
            </div>

            <div className="p-6 border-t border-white/10 flex items-center justify-between bg-white/[0.02]">
              <div className="flex items-center gap-4">
                <button 
                  onClick={toggleTheme}
                  className="flex items-center justify-center w-12 h-12 bg-white/5 rounded-full border border-white/10 text-white/60 hover:text-white transition-all"
                  title="Switch Theme"
                >
                  {theme === 'bitget' ? <Zap size={18} className="text-primary" /> : <Leaf size={18} className="text-emerald-500" />}
                </button>
                {userName && (
                  <div className="flex flex-col">
                    <span className="text-[8px] font-bold text-white/20 uppercase tracking-widest">Active Identity</span>
                    <span className="text-xs font-bold">{userName}</span>
                  </div>
                )}
              </div>
              <button 
                onClick={handleSignOut}
                className="text-red-400 text-xs font-black tracking-widest px-4 py-2 hover:bg-red-400/10 rounded-full transition-all"
              >
                SIGN OUT
              </button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </nav>
  )
}
