import api from './api';

export const authService = {
  /**
   * Register a new user
   * @param {Object} data - Registration data
   * @param {string} data.email - User email
   * @param {string} data.name - User name
   * @param {string} data.password - User password
   * @param {string} data.confirmPassword - Password confirmation
   * @returns {Promise} API response
   */
  register: async (data) => {
    const response = await api.post('/auth/register', data);
    return response.data;
  },

  /**
   * Login user
   * @param {Object} credentials - Login credentials
   * @param {string} credentials.email - User email
   * @param {string} credentials.password - User password
   * @returns {Promise} API response
   */
  login: async (credentials) => {
    const response = await api.post('/auth/login', credentials);
    if (response.data.success && response.data.data.token) {
      localStorage.setItem('token', response.data.data.token);
    }
    return response.data;
  },

  /**
   * Logout user
   * @returns {Promise} API response
   */
  logout: async () => {
    const response = await api.post('/auth/logout');
    localStorage.removeItem('token');
    return response.data;
  },

  /**
   * Get current user profile
   * @returns {Promise} API response
   */
  getProfile: async () => {
    const response = await api.get('/auth/me');
    return response.data;
  }
};

export default authService;
