import React, { useState, useEffect } from 'react';
import api from '../api';

const Parents = () => {
  const [parents, setParents] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchParents = async () => {
      try {
        const response = await api.get('/admin/parents');
        setParents(response.data);
      } catch (error) {
        console.error('Failed to fetch parents:', error);
      } finally {
        setLoading(false);
      }
    };
    fetchParents();
  }, []);

  if (loading) return <div className="loader-container"><div className="loader"></div></div>;

  return (
    <div>
      <h1 style={{ marginBottom: '2rem' }}>Manage Parents</h1>
      <div className="table-container glass-panel">
        <div className="table-header">
          <h2>Parents List ({parents.length})</h2>
        </div>
        <div style={{ overflowX: 'auto' }}>
          <table>
            <thead>
              <tr>
                <th>Parent Name</th>
                <th>Child Name</th>
                <th>Email</th>
                <th>Phone</th>
                <th>Connected Driver</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              {parents.map((parent) => (
                <tr key={parent._id}>
                  <td>{parent.user?.name || 'Unknown'}</td>
                  <td>{parent.child_name || 'N/A'}</td>
                  <td>{parent.user?.email || 'N/A'}</td>
                  <td>{parent.user?.phone || 'N/A'}</td>
                  <td>
                    {parent.connected_driver ? (
                      <span className="badge badge-info">{parent.connected_driver.name}</span>
                    ) : (
                      <span className="badge badge-warning">Unassigned</span>
                    )}
                  </td>
                  <td>
                    <span className={`badge ${parent.user?.isActive ? 'badge-success' : 'badge-danger'}`}>
                      {parent.user?.isActive ? 'Active' : 'Suspended'}
                    </span>
                  </td>
                </tr>
              ))}
              {parents.length === 0 && (
                <tr>
                  <td colSpan="6" style={{ textAlign: 'center', padding: '2rem' }}>No parents found.</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default Parents;
