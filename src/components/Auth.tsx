import { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { X, Mail, Lock, User as UserIcon, ArrowRight, Globe, ShieldCheck, Phone, MapPin, Briefcase, Eye, EyeOff, Loader2, AlertCircle } from 'lucide-react'
import { GlassCard } from './ui/GlassCard'
import { cn } from '../lib/utils'
import { 
  signInWithEmailAndPassword, 
  createUserWithEmailAndPassword,
  updateProfile,
  signInWithPopup
} from 'firebase/auth'
import { doc, setDoc, getDoc } from 'firebase/firestore'
import { auth, db, googleProvider } from '../lib/firebase'

type AuthMode = 'login' | 'signup'

export function Auth({ isOpen, onClose, initialMode = 'login' }: { isOpen: boolean, onClose: () => void, initialMode?: AuthMode }) {
  const [mode, setMode] = useState<AuthMode>(initialMode)
  const [isFarmer, setIsFarmer] = useState(false)
  const [showPassword, setShowPassword] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  // Form States
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [fullName, setFullName] = useState('')
  const [phone, setPhone] = useState('')
  const [location, setLocation] = useState('Savannah Belt')

  useEffect(() => {
    if (isOpen) {
      setMode(initialMode)
      setError(null)
    }
  }, [isOpen, initialMode])

  const handleAuth = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)
    setError(null)

    try {
      if (mode === 'signup') {
        const userCredential = await createUserWithEmailAndPassword(auth, email, password)
        const user = userCredential.user

        // Update profile with name
        await updateProfile(user, { displayName: fullName })

        // Save extra metadata to Firestore
        await setDoc(doc(db, 'users', user.uid), {
          fullName,
          phone,
          location,
          isFarmer,
          createdAt: new Date().toISOString()
        })
      } else {
        await signInWithEmailAndPassword(auth, email, password)
      }
      onClose()
    } catch (err: any) {
      console.error('Auth Error:', err)
      setError(err.message || 'An error occurred during authentication')
    } finally {
      setIsLoading(false)
    }
  }

  const handleGoogleAuth = async () => {
    setIsLoading(true)
    setError(null)
    try {
      const result = await signInWithPopup(auth, googleProvider)
      const user = result.user

      // Check if user exists in Firestore
      const userDoc = await getDoc(doc(db, 'users', user.uid))
      if (!userDoc.exists()) {
        // Create default profile for first-time Google user
        await setDoc(doc(db, 'users', user.uid), {
          fullName: user.displayName || 'User',
          email: user.email,
          phone: '',
          location: 'Savannah Belt',
          isFarmer: false,
          createdAt: new Date().toISOString(),
          provider: 'google'
        })
      }
      onClose()
    } catch (err: any) {
      console.error('Google Auth Error:', err)
      setError(err.message || 'Failed to sign in with Google')
    } finally {
      setIsLoading(false)
    }
  }

  if (!isOpen) return null

  return (
    <div className="fixed inset-0 z-[110] flex items-center justify-center p-6 bg-black/40 backdrop-blur-sm">
      <motion.div
        initial={{ opacity: 0, scale: 0.95, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.95, y: 20 }}
        className="w-full max-w-md"
      >
        <GlassCard className="relative p-6 md:p-10 border-white/10 shadow-2xl overflow-hidden flex flex-col max-h-[90vh]">
          <button 
            onClick={onClose}
            className="absolute top-4 right-4 z-[120] p-3 rounded-full bg-white/5 border border-white/10 hover:bg-white/10 transition-all text-white/40 hover:text-white backdrop-blur-xl"
          >
            <X size={20} />
          </button>

          <div className="flex-1 overflow-y-auto pr-2 custom-scrollbar">
            <div className="text-center mb-8">
              <h2 className="text-3xl md:text-4xl font-bold tracking-tighter italic mb-2">
                {mode === 'login' ? 'Welcome back!' : 'Create your account'}
              </h2>
              <p className="text-white/40 text-xs md:text-sm mb-6">
                Secure your account and keep your harvest results with you on any device.
              </p>
            </div>

            {error && (
              <motion.div 
                initial={{ opacity: 0, y: -10 }}
                animate={{ opacity: 1, y: 0 }}
                className="mb-6 p-4 rounded-2xl bg-red-500/10 border border-red-500/20 text-red-400 text-xs flex flex-col gap-2"
              >
                <div className="flex items-center gap-3">
                  <AlertCircle size={16} />
                  <span>{error}</span>
                </div>
                {error.includes('window.closed') || error.includes('popup') ? (
                  <p className="text-[10px] text-white/40 mt-1 pl-7 leading-relaxed">
                    Tip: If you're on a local development server, ensure your browser isn't blocking popups. Alternatively, try using the Email/Password sign-in.
                  </p>
                ) : null}
              </motion.div>
            )}

          <form className="space-y-6" onSubmit={handleAuth}>
            <AnimatePresence mode="wait">
              {mode === 'signup' ? (
                <motion.div
                  key="signup"
                  initial={{ opacity: 0, x: 20 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: -20 }}
                  className="space-y-4"
                >
                  <div className="space-y-2">
                    <label className="text-[10px] uppercase tracking-widest font-bold text-primary/80 ml-1">Full Name</label>
                    <div className="relative group">
                      <UserIcon className="absolute left-4 top-1/2 -translate-y-1/2 text-white/20 group-focus-within:text-primary transition-colors" size={18} />
                      <input 
                        required
                        type="text" 
                        value={fullName}
                        onChange={(e) => setFullName(e.target.value)}
                        placeholder="Dr. Savannah" 
                        className="w-full bg-white/5 border border-white/5 rounded-2xl py-4 pl-12 pr-4 text-sm focus:outline-none focus:border-primary/50 transition-all"
                      />
                    </div>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div className="space-y-2">
                      <label className="text-[10px] uppercase tracking-widest font-bold text-primary/80 ml-1">Phone Number</label>
                      <div className="relative group">
                        <Phone className="absolute left-4 top-1/2 -translate-y-1/2 text-white/20 group-focus-within:text-primary transition-colors" size={18} />
                        <input 
                          required
                          type="tel" 
                          value={phone}
                          onChange={(e) => setPhone(e.target.value)}
                          placeholder="+234..." 
                          className="w-full bg-white/5 border border-white/5 rounded-2xl py-4 pl-12 pr-4 text-sm focus:outline-none focus:border-primary/50 transition-all"
                        />
                      </div>
                    </div>
                    <div className="space-y-2">
                      <label className="text-[10px] uppercase tracking-widest font-bold text-primary/80 ml-1">Location</label>
                      <div className="relative group">
                        <MapPin className="absolute left-4 top-1/2 -translate-y-1/2 text-white/20 group-focus-within:text-primary transition-colors" size={18} />
                        <select 
                          value={location}
                          onChange={(e) => setLocation(e.target.value)}
                          className="w-full bg-white/5 border border-white/5 rounded-2xl py-4 pl-12 pr-4 text-sm focus:outline-none focus:border-primary/50 transition-all appearance-none"
                        >
                          <option className="bg-[#111318]" value="Savannah Belt">Savannah Belt</option>
                          <option className="bg-[#111318]" value="Northern Region">Northern Region</option>
                          <option className="bg-[#111318]" value="Southern Forest">Southern Forest</option>
                          <option className="bg-[#111318]" value="Delta Area">Delta Area</option>
                        </select>
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center gap-4 p-4 rounded-2xl bg-primary/5 border border-primary/10 group/farmer cursor-pointer" onClick={() => setIsFarmer(!isFarmer)}>
                    <div className={cn("p-2 rounded-xl transition-all", isFarmer ? "bg-primary text-white" : "bg-white/5 text-white/20")}>
                      <Briefcase size={20} />
                    </div>
                    <div className="flex-1">
                      <p className="text-sm font-bold text-white/90">Are you a Farmer?</p>
                      <p className="text-[10px] text-white/40">Custom advice for field work.</p>
                    </div>
                    <div className={cn("w-10 h-6 rounded-full transition-all relative", isFarmer ? "bg-primary" : "bg-white/10")}>
                      <motion.div 
                        animate={{ x: isFarmer ? 16 : 4 }}
                        className="absolute top-1 w-4 h-4 rounded-full bg-white shadow-lg"
                      />
                    </div>
                  </div>

                  <div className="space-y-2">
                    <label className="text-[10px] uppercase tracking-widest font-bold text-primary/80 ml-1">Email Address</label>
                    <div className="relative group">
                      <Mail className="absolute left-4 top-1/2 -translate-y-1/2 text-white/20 group-focus-within:text-primary transition-colors" size={18} />
                      <input 
                        required
                        type="email" 
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        placeholder="hello@yourfarm.com" 
                        className="w-full bg-white/5 border border-white/5 rounded-2xl py-4 pl-12 pr-4 text-sm focus:outline-none focus:border-primary/50 transition-all"
                      />
                    </div>
                  </div>

                  <div className="space-y-2">
                    <label className="text-[10px] uppercase tracking-widest font-bold text-primary/80 ml-1">Create Password</label>
                    <div className="relative group">
                      <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-white/20 group-focus-within:text-primary transition-colors" size={18} />
                      <input 
                        required
                        type={showPassword ? "text" : "password"} 
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        placeholder="••••••••" 
                        className="w-full bg-white/5 border border-white/5 rounded-2xl py-4 pl-12 pr-12 text-sm focus:outline-none focus:border-primary/50 transition-all font-mono"
                      />
                      <button
                        type="button"
                        onClick={() => setShowPassword(!showPassword)}
                        className="absolute right-4 top-1/2 -translate-y-1/2 text-white/20 hover:text-white transition-colors"
                      >
                        {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                      </button>
                    </div>
                  </div>

                  <button 
                    type="submit"
                    disabled={isLoading}
                    className="w-full py-5 bg-primary text-white font-bold rounded-2xl hover:bg-primary/90 transition-all shadow-[0_15px_40px_rgba(108,58,250,0.3)] flex items-center justify-center gap-2 group mt-4 uppercase tracking-[0.3em] text-xs disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {isLoading ? (
                      <Loader2 size={18} className="animate-spin" />
                    ) : (
                      <>
                        Create Account
                        <ArrowRight size={18} className="group-hover:translate-x-1 transition-transform" />
                      </>
                    )}
                  </button>

                  <div className="flex items-center gap-4 my-2">
                    <div className="h-[1px] flex-1 bg-white/5" />
                    <span className="text-[10px] text-white/20 font-bold uppercase tracking-widest">or</span>
                    <div className="h-[1px] flex-1 bg-white/5" />
                  </div>

                  <button 
                    type="button"
                    onClick={handleGoogleAuth}
                    disabled={isLoading}
                    className="w-full py-4 bg-white/5 border border-white/10 text-white font-bold rounded-2xl hover:bg-white/10 transition-all flex items-center justify-center gap-3 text-[10px] uppercase tracking-widest disabled:opacity-50"
                  >
                    <img src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg" className="w-5 h-5" alt="Google" />
                    Continue with Google
                  </button>

                  <div className="flex items-center gap-4 my-2">
                    <div className="h-[1px] flex-1 bg-white/5" />
                    <span className="text-[10px] text-white/20 font-bold uppercase tracking-widest">or</span>
                    <div className="h-[1px] flex-1 bg-white/5" />
                  </div>

                  <button 
                    type="button"
                    onClick={() => setMode('login')}
                    className="w-full py-4 border border-white/10 text-white/40 hover:text-white hover:bg-white/5 rounded-2xl transition-all text-[10px] font-bold uppercase tracking-[0.2em]"
                  >
                    Already have an account? Sign In
                  </button>
                </motion.div>
              ) : (
                <motion.div
                  key="login"
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  exit={{ opacity: 0, x: 20 }}
                  className="space-y-4"
                >
                  <div className="space-y-2">
                    <label className="text-[10px] uppercase tracking-widest font-bold text-primary/80 ml-1">Email Address</label>
                    <div className="relative group">
                      <Mail className="absolute left-4 top-1/2 -translate-y-1/2 text-white/20 group-focus-within:text-primary transition-colors" size={18} />
                      <input 
                        required
                        type="email" 
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        placeholder="hello@yourfarm.com" 
                        className="w-full bg-white/5 border border-white/5 rounded-2xl py-4 pl-12 pr-4 text-sm focus:outline-none focus:border-primary/50 transition-all"
                      />
                    </div>
                  </div>

                  <div className="space-y-2">
                    <div className="flex justify-between items-center px-1">
                      <label className="text-[10px] uppercase tracking-widest font-bold text-primary/80">Your Password</label>
                      <button type="button" className="text-[10px] uppercase tracking-widest font-bold text-white/20 hover:text-primary/60 transition-colors">Forgot?</button>
                    </div>
                    <div className="relative group">
                      <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-white/20 group-focus-within:text-primary transition-colors" size={18} />
                      <input 
                        required
                        type={showPassword ? "text" : "password"} 
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        placeholder="••••••••" 
                        className="w-full bg-white/5 border border-white/5 rounded-2xl py-4 pl-12 pr-12 text-sm focus:outline-none focus:border-primary/50 transition-all font-mono"
                      />
                      <button
                        type="button"
                        onClick={() => setShowPassword(!showPassword)}
                        className="absolute right-4 top-1/2 -translate-y-1/2 text-white/20 hover:text-white transition-colors"
                      >
                        {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                      </button>
                    </div>
                  </div>

                  <button 
                    type="submit"
                    disabled={isLoading}
                    className="w-full py-5 bg-primary text-white font-bold rounded-2xl hover:bg-primary/90 transition-all shadow-[0_15px_40px_rgba(108,58,250,0.3)] flex items-center justify-center gap-2 group mt-4 uppercase tracking-[0.3em] text-xs disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    {isLoading ? (
                      <Loader2 size={18} className="animate-spin" />
                    ) : (
                      <>
                        Sign In
                        <ArrowRight size={18} className="group-hover:translate-x-1 transition-transform" />
                      </>
                    )}
                  </button>

                  <div className="flex items-center gap-4 my-2">
                    <div className="h-[1px] flex-1 bg-white/5" />
                    <span className="text-[10px] text-white/20 font-bold uppercase tracking-widest">or</span>
                    <div className="h-[1px] flex-1 bg-white/5" />
                  </div>

                  <button 
                    type="button"
                    onClick={handleGoogleAuth}
                    disabled={isLoading}
                    className="w-full py-4 bg-white/5 border border-white/10 text-white font-bold rounded-2xl hover:bg-white/10 transition-all flex items-center justify-center gap-3 text-[10px] uppercase tracking-widest disabled:opacity-50"
                  >
                    <img src="https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg" className="w-5 h-5" alt="Google" />
                    Sign in with Google
                  </button>

                  <div className="flex items-center gap-4 my-2">
                    <div className="h-[1px] flex-1 bg-white/5" />
                    <span className="text-[10px] text-white/20 font-bold uppercase tracking-widest">or</span>
                    <div className="h-[1px] flex-1 bg-white/5" />
                  </div>

                  <button 
                    type="button"
                    onClick={() => setMode('signup')}
                    className="w-full py-4 border border-white/10 text-white/40 hover:text-white hover:bg-white/5 rounded-2xl transition-all text-[10px] font-bold uppercase tracking-[0.2em]"
                  >
                    New here? Create Account
                  </button>
                </motion.div>
              )}
            </AnimatePresence>
          </form>

          <div className="mt-8 text-center text-white/10 uppercase tracking-[0.3em] text-[8px] font-black">
            Powered by White Walkers
          </div>
        </div>
      </GlassCard>
    </motion.div>
  </div>
  )
}
