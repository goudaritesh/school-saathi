import React, { useState, useEffect } from 'react';
import { Users, Car, AlertCircle, CreditCard, CalendarOff } from 'lucide-react';
import api from '../api';

const Dashboard = () => {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const response = await api.get('/admin/stats');
        setStats(response.data);
      } catch (error) {
        console.error('Failed to fetch stats:', error);
      } finally {
        setLoading(false);
      }
    };
    fetchStats();
  }, []);

  if (loading) {
    return <div className="loader-container"><div className="loader"></div></div>;
  }

  return (
    <div>
      <h1 style={{ marginBottom: '2rem' }}>Dashboard Overview</h1>
      
      <div className="dashboard-grid">
        <div className="card stat-card">
          <div className="stat-icon" style={{ backgroundColor: 'var(--primary-color)' }}>
            <Car size={24} />
          </div>
          <div className="stat-info">
            <h3>Active Drivers</h3>
            <p>{stats?.totalDrivers || 0}</p>
          </div>
        </div>

        <div className="card stat-card">
          <div className="stat-icon" style={{ backgroundColor: 'var(--secondary-color)' }}>
            <Users size={24} />
          </div>
          <div className="stat-info">
            <h3>Active Parents</h3>
            <p>{stats?.totalParents || 0}</p>
          </div>
        </div>

        <div className="card stat-card">
          <div className="stat-icon" style={{ backgroundColor: 'var(--warning-color)' }}>
            <AlertCircle size={24} />
          </div>
          <div className="stat-info">
            <h3>Open Complaints</h3>
            <p>{stats?.complaints || 0}</p>
          </div>
        </div>

        <div className="card stat-card">
          <div className="stat-icon" style={{ backgroundColor: 'var(--info-color)' }}>
            <CalendarOff size={24} />
          </div>
          <div className="stat-info">
            <h3>Pending Leaves</h3>
            <p>{stats?.leaveRequests || 0}</p>
          </div>
        </div>

        <div className="card stat-card">
          <div className="stat-icon" style={{ backgroundColor: '#8b5cf6' }}>
            <CreditCard size={24} />
          </div>
          <div className="stat-info">
            <h3>Total Revenue</h3>
            <p>₹{stats?.totalRevenue || 0}</p>
          </div>
        </div>
      </div>

      <div className="card glass-panel" style={{ marginTop: '2rem' }}>
        <h2>System Activity</h2>
        <p style={{ color: 'var(--text-secondary)' }}>Today's operations snapshot.</p>
        <div style={{ display: 'flex', gap: '2rem', marginTop: '1.5rem' }}>
          <div>
            <h4 style={{ color: 'var(--text-secondary)', marginBottom: '0.5rem' }}>Active Vans Today</h4>
            <span style={{ fontSize: '2rem', fontWeight: 'bold' }}>{stats?.activeVans || 0}</span>
          </div>
          <div>
            <h4 style={{ color: 'var(--text-secondary)', marginBottom: '0.5rem' }}>Today's Pickups</h4>
            <span style={{ fontSize: '2rem', fontWeight: 'bold', color: 'var(--secondary-color)' }}>{stats?.todayPickup || 0}</span>
          </div>
          <div>
            <h4 style={{ color: 'var(--text-secondary)', marginBottom: '0.5rem' }}>Today's Drops</h4>
            <span style={{ fontSize: '2rem', fontWeight: 'bold', color: 'var(--info-color)' }}>{stats?.todayDrop || 0}</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
