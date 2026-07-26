import React, { useState, useEffect } from 'react';
import api from '../api';

const Drivers = () => {
  const [drivers, setDrivers] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchDrivers = async () => {
      try {
        const response = await api.get('/admin/drivers');
        setDrivers(response.data);
      } catch (error) {
        console.error('Failed to fetch drivers:', error);
      } finally {
        setLoading(false);
      }
    };
    fetchDrivers();
  }, []);

  if (loading) return <div className="loader-container"><div className="loader"></div></div>;

  return (
    <div>
      <h1 style={{ marginBottom: '2rem' }}>Manage Drivers</h1>
      <div className="table-container glass-panel">
        <div className="table-header">
          <h2>Drivers List ({drivers.length})</h2>
        </div>
        <div style={{ overflowX: 'auto' }}>
          <table>
            <thead>
              <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Phone</th>
                <th>Status</th>
                <th>License No</th>
              </tr>
            </thead>
            <tbody>
              {drivers.map((driver) => (
                <tr key={driver._id}>
                  <td>{driver.user?.name || 'Unknown'}</td>
                  <td>{driver.user?.email || 'N/A'}</td>
                  <td>{driver.user?.phone || 'N/A'}</td>
                  <td>
                    <span className={`badge ${driver.user?.isActive ? 'badge-success' : 'badge-danger'}`}>
                      {driver.user?.isActive ? 'Active' : 'Suspended'}
                    </span>
                  </td>
                  <td>{driver.licenseNumber || 'N/A'}</td>
                </tr>
              ))}
              {drivers.length === 0 && (
                <tr>
                  <td colSpan="5" style={{ textAlign: 'center', padding: '2rem' }}>No drivers found.</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default Drivers;
