import { useState } from 'react'
import { motion } from 'framer-motion'
import { User, Mail, MapPin, Phone, ShieldCheck, Save, Bell, Lock, Eye, EyeOff } from 'lucide-react'
import { cn } from '../lib/utils'
import { GlassCard } from './ui/GlassCard'

export function ProfileSettings() {
  const [activeTab, setActiveTab] = useState<'info' | 'notifications' | 'security'>('info')
  const [isFarmer, setIsFarmer] = useState(true)
  const [showCurrentPass, setShowCurrentPass] = useState(false)
  const [showNewPass, setShowNewPass] = useState(false)

  return (
    <div className="max-w-4xl mx-auto space-y-12 pb-24">
      <div>
        <h1 className="text-5xl font-bold tracking-tighter italic mb-2">Account <span className="text-primary not-italic font-black">SETTINGS</span></h1>
        <p className="text-white/40 text-sm">Manage your agricultural profile and platform preferences.</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
        <div className="md:col-span-1 space-y-4">
          <GlassCard className="p-6 border-white/5 bg-white/5">
            <div className="flex flex-col items-center text-center">
              <div className="w-24 h-24 rounded-full bg-primary/20 border-2 border-primary flex items-center justify-center mb-4 relative">
                <User size={40} className="text-primary" />
                <div className="absolute bottom-0 right-0 p-1.5 bg-primary text-black rounded-full border-4 border-[#0d0f14]">
                  <ShieldCheck size={12} />
                </div>
              </div>
              <h3 className="font-bold text-lg">Alex</h3>
              <p className="text-[10px] text-white/40 uppercase tracking-widest">Premium Farmer</p>
            </div>
            
            <nav className="mt-8 space-y-2">
              <button 
                onClick={() => setActiveTab('info')}
                className={cn(
                  "w-full text-left px-4 py-3 rounded-xl font-bold text-xs flex items-center gap-3 transition-all",
                  activeTab === 'info' ? "bg-primary text-black" : "text-white/40 hover:bg-white/5 hover:text-white"
                )}
              >
                <User size={16} /> Personal Info
              </button>
              <button 
                onClick={() => setActiveTab('notifications')}
                className={cn(
                  "w-full text-left px-4 py-3 rounded-xl font-bold text-xs flex items-center gap-3 transition-all",
                  activeTab === 'notifications' ? "bg-primary text-black" : "text-white/40 hover:bg-white/5 hover:text-white"
                )}
              >
                <Bell size={16} /> Notifications
              </button>
              <button 
                onClick={() => setActiveTab('security')}
                className={cn(
                  "w-full text-left px-4 py-3 rounded-xl font-bold text-xs flex items-center gap-3 transition-all",
                  activeTab === 'security' ? "bg-primary text-black" : "text-white/40 hover:bg-white/5 hover:text-white"
                )}
              >
                <Lock size={16} /> Security
              </button>
            </nav>
          </GlassCard>
        </div>

        <div className="md:col-span-2 space-y-6">
          {activeTab === 'info' && (
            <GlassCard className="p-8 border-white/5 bg-white/5">
              <h3 className="text-xl font-bold mb-8 italic">Personal Information</h3>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-2">
                  <label className="text-[10px] font-bold text-white/40 uppercase tracking-widest ml-1">Full Name</label>
                  <div className="relative">
                    <User className="absolute left-4 top-1/2 -translate-y-1/2 text-white/20" size={18} />
                    <input 
                      type="text" 
                      defaultValue="Alex"
                      className="w-full bg-white/5 border border-white/10 rounded-2xl py-3 pl-12 pr-4 focus:border-primary/50 focus:ring-1 focus:ring-primary/50 outline-none transition-all"
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <label className="text-[10px] font-bold text-white/40 uppercase tracking-widest ml-1">Email Address</label>
                  <div className="relative">
                    <Mail className="absolute left-4 top-1/2 -translate-y-1/2 text-white/20" size={18} />
                    <input 
                      type="email" 
                      defaultValue="alex@farm.tech"
                      className="w-full bg-white/5 border border-white/10 rounded-2xl py-3 pl-12 pr-4 focus:border-primary/50 focus:ring-1 focus:ring-primary/50 outline-none transition-all"
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <label className="text-[10px] font-bold text-white/40 uppercase tracking-widest ml-1">Location</label>
                  <div className="relative">
                    <MapPin className="absolute left-4 top-1/2 -translate-y-1/2 text-white/20" size={18} />
                    <input 
                      type="text" 
                      defaultValue="Savannah Belt Region"
                      className="w-full bg-white/5 border border-white/10 rounded-2xl py-3 pl-12 pr-4 focus:border-primary/50 focus:ring-1 focus:ring-primary/50 outline-none transition-all"
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <label className="text-[10px] font-bold text-white/40 uppercase tracking-widest ml-1">Phone Number</label>
                  <div className="relative">
                    <Phone className="absolute left-4 top-1/2 -translate-y-1/2 text-white/20" size={18} />
                    <input 
                      type="tel" 
                      defaultValue="+1 234 567 8900"
                      className="w-full bg-white/5 border border-white/10 rounded-2xl py-3 pl-12 pr-4 focus:border-primary/50 focus:ring-1 focus:ring-primary/50 outline-none transition-all"
                    />
                  </div>
                </div>
              </div>

              <div className="mt-8 p-6 bg-primary/5 border border-primary/10 rounded-2xl">
                <div className="flex items-center justify-between">
                  <div>
                    <h4 className="font-bold text-sm">Professional Farmer Status</h4>
                    <p className="text-[10px] text-white/40">Enable specialized agronomy tools and personalized advice.</p>
                  </div>
                  <button 
                    onClick={() => setIsFarmer(!isFarmer)}
                    className={`w-12 h-6 rounded-full transition-all relative ${isFarmer ? 'bg-primary' : 'bg-white/10'}`}
                  >
                    <div className={`absolute top-1 w-4 h-4 rounded-full bg-white transition-all ${isFarmer ? 'left-7' : 'left-1'}`} />
                  </button>
                </div>
              </div>

              <div className="mt-12 flex justify-end">
                <button className="flex items-center gap-2 px-8 py-3 bg-primary text-black rounded-2xl font-bold uppercase tracking-widest shadow-lg shadow-primary/20 hover:scale-105 transition-transform active:scale-95">
                  <Save size={18} />
                  Save Changes
                </button>
              </div>
            </GlassCard>
          )}

          {activeTab === 'security' && (
            <GlassCard className="p-8 border-white/5 bg-white/5">
              <h3 className="text-xl font-bold mb-8 italic">Security Settings</h3>
              
              <div className="space-y-8">
                <div className="grid grid-cols-1 gap-6">
                  <div className="space-y-2">
                    <label className="text-[10px] font-bold text-white/40 uppercase tracking-widest ml-1">Change Password</label>
                    <div className="relative">
                      <input 
                        type={showCurrentPass ? "text" : "password"} 
                        placeholder="Current Password"
                        className="w-full bg-white/5 border border-white/10 rounded-2xl py-3 px-4 pr-12 focus:border-primary/50 outline-none transition-all font-mono"
                      />
                      <button
                        onClick={() => setShowCurrentPass(!showCurrentPass)}
                        className="absolute right-4 top-1/2 -translate-y-1/2 text-white/20 hover:text-white transition-colors"
                      >
                        {showCurrentPass ? <EyeOff size={16} /> : <Eye size={16} />}
                      </button>
                    </div>
                    <div className="grid grid-cols-2 gap-4">
                      <div className="relative">
                        <input 
                          type={showNewPass ? "text" : "password"} 
                          placeholder="New Password"
                          className="w-full bg-white/5 border border-white/10 rounded-2xl py-3 px-4 pr-12 focus:border-primary/50 outline-none transition-all font-mono"
                        />
                        <button
                          onClick={() => setShowNewPass(!showNewPass)}
                          className="absolute right-4 top-1/2 -translate-y-1/2 text-white/20 hover:text-white transition-colors"
                        >
                          {showNewPass ? <EyeOff size={16} /> : <Eye size={16} />}
                        </button>
                      </div>
                      <input 
                        type={showNewPass ? "text" : "password"} 
                        placeholder="Confirm New Password"
                        className="w-full bg-white/5 border border-white/10 rounded-2xl py-3 px-4 focus:border-primary/50 outline-none transition-all font-mono"
                      />
                    </div>
                  </div>
                </div>

                <div className="p-6 bg-white/5 border border-white/5 rounded-2xl">
                  <div className="flex items-center justify-between">
                    <div>
                      <h4 className="font-bold text-sm">Two-Factor Authentication</h4>
                      <p className="text-[10px] text-white/40">Add a second layer of security to your account.</p>
                    </div>
                    <button className="px-4 py-2 bg-white/10 rounded-xl text-[10px] font-bold uppercase tracking-widest hover:bg-white/20 transition-all">
                      Configure
                    </button>
                  </div>
                </div>

                <div className="p-6 bg-white/5 border border-white/5 rounded-2xl">
                  <div className="flex items-center justify-between">
                    <div>
                      <h4 className="font-bold text-sm text-red-400">Delete Account</h4>
                      <p className="text-[10px] text-white/40 italic">Permanently remove your account and all field data.</p>
                    </div>
                    <button className="px-4 py-2 bg-red-400/10 text-red-400 rounded-xl text-[10px] font-bold uppercase tracking-widest hover:bg-red-400/20 transition-all border border-red-400/20">
                      Delete
                    </button>
                  </div>
                </div>
              </div>

              <div className="mt-12 flex justify-end">
                <button className="flex items-center gap-2 px-8 py-3 bg-primary text-black rounded-2xl font-bold uppercase tracking-widest shadow-lg shadow-primary/20 hover:scale-105 transition-transform active:scale-95">
                  <Save size={18} />
                  Update Security
                </button>
              </div>
            </GlassCard>
          )}

          {activeTab === 'notifications' && (
            <GlassCard className="p-8 border-white/5 bg-white/5">
              <h3 className="text-xl font-bold mb-8 italic">Notice Preferences</h3>
              <p className="text-white/40 text-sm italic">You currently have all field notices enabled.</p>
            </GlassCard>
          )}
        </div>
      </div>
    </div>
  )
}
