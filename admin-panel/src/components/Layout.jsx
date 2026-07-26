import React from 'react';
import { Outlet, NavLink, useNavigate } from 'react-router-dom';
import { 
  LayoutDashboard, 
  Users, 
  Car, 
  MessageSquareWarning, 
  CalendarOff,
  LifeBuoy,
  CreditCard,
  LogOut
} from 'lucide-react';

const Layout = () => {
  const navigate = useNavigate();

  const handleLogout = () => {
    localStorage.removeItem('adminToken');
    navigate('/login');
  };

  return (
    <div className="app-container">
      <aside className="sidebar">
        <div className="sidebar-logo">
          <div style={{ width: '32px', height: '32px', background: 'var(--primary-color)', borderRadius: '8px', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'white' }}>
            S
          </div>
          School Sathi
        </div>
        
        <nav style={{ display: 'flex', flexDirection: 'column', gap: '0.5rem', flex: 1 }}>
          <NavLink to="/" className={({isActive}) => isActive ? "nav-link active" : "nav-link"} end>
            <LayoutDashboard size={20} /> Dashboard
          </NavLink>
          <NavLink to="/drivers" className={({isActive}) => isActive ? "nav-link active" : "nav-link"}>
            <Car size={20} /> Drivers
          </NavLink>
          <NavLink to="/parents" className={({isActive}) => isActive ? "nav-link active" : "nav-link"}>
            <Users size={20} /> Parents
          </NavLink>
          <NavLink to="/complaints" className={({isActive}) => isActive ? "nav-link active" : "nav-link"}>
            <MessageSquareWarning size={20} /> Complaints
          </NavLink>
          <NavLink to="/leaves" className={({isActive}) => isActive ? "nav-link active" : "nav-link"}>
            <CalendarOff size={20} /> Leave Requests
          </NavLink>
          <NavLink to="/support" className={({isActive}) => isActive ? "nav-link active" : "nav-link"}>
            <LifeBuoy size={20} /> Help & Support
          </NavLink>
          <NavLink to="/payments" className={({isActive}) => isActive ? "nav-link active" : "nav-link"}>
            <CreditCard size={20} /> Payments
          </NavLink>
        </nav>

        <button 
          onClick={handleLogout} 
          style={{ display: 'flex', alignItems: 'center', gap: '0.75rem', padding: '0.75rem 1rem', background: 'none', border: 'none', color: 'var(--danger-color)', cursor: 'pointer', fontWeight: 500, marginTop: 'auto', borderRadius: '0.5rem' }}
          onMouseOver={(e) => e.currentTarget.style.backgroundColor = 'rgba(239,68,68,0.1)'}
          onMouseOut={(e) => e.currentTarget.style.backgroundColor = 'transparent'}
        >
          <LogOut size={20} /> Logout
        </button>
      </aside>

      <main className="main-content">
        <Outlet />
      </main>
    </div>
  );
};

export default Layout;
