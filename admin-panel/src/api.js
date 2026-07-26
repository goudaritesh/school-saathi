import axios from 'axios';

const api = axios.create({
  baseURL: 'https://school-saathi-api.onrender.com/api', // Backend URL
});

// Add a request interceptor to include the admin token (mocked for now, or assumed logged in)
api.interceptors.request.use((config) => {
  // In a real app, fetch token from localStorage
  // const token = localStorage.getItem('token');
  // if (token) {
  //   config.headers.Authorization = `Bearer ${token}`;
  // }

  // For development without auth setup on React side yet, we might need a workaround or we can assume it works if we add auth later.
  // Actually, backend has `authorize('Admin')` which requires a valid JWT token. 
  // Let's create a simple login if needed, or rely on a hardcoded test token.
  const token = localStorage.getItem('adminToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export default api;
