import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { Link, useNavigate } from 'react-router-dom';
import { BookMarked, Mail, User, Lock, CheckCircle, XCircle } from 'lucide-react';
import authService from '../services/auth.service';

function Register() {
  const navigate = useNavigate();
  const [isLoading, setIsLoading] = useState(false);
  const [serverError, setServerError] = useState('');
  const [successMessage, setSuccessMessage] = useState('');

  const {
    register,
    handleSubmit,
    watch,
    formState: { errors }
  } = useForm();

  const password = watch('password');

  const onSubmit = async (data) => {
    try {
      setIsLoading(true);
      setServerError('');
      setSuccessMessage('');

      const response = await authService.register(data);

      if (response.success) {
        setSuccessMessage(response.message);
        // Redirect to login after 2 seconds
        setTimeout(() => {
          navigate('/login');
        }, 2000);
      }
    } catch (error) {
      console.error('Registration error:', error);

      if (error.response?.data?.message) {
        setServerError(error.response.data.message);
      } else if (error.response?.data?.errors) {
        const errorMessages = error.response.data.errors
          .map(err => err.message)
          .join(', ');
        setServerError(errorMessages);
      } else {
        setServerError('Đã xảy ra lỗi. Vui lòng thử lại sau.');
      }
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-paper-50 via-white to-wood-50 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full">
        {/* Logo and Header */}
        <div className="text-center mb-8">
          <Link to="/" className="inline-flex items-center space-x-2 mb-6">
            <BookMarked className="w-10 h-10 text-ink-800" />
            <span className="text-3xl font-bold text-ink-900">LibraryHub</span>
          </Link>
          <h2 className="text-3xl font-bold text-ink-900 mb-2">Tạo tài khoản</h2>
          <p className="text-ink-600">Đăng ký để bắt đầu mượn sách ngay hôm nay</p>
        </div>

        {/* Registration Form */}
        <div className="card p-8 shadow-soft-lg">
          {/* Success Message */}
          {successMessage && (
            <div className="mb-6 p-4 bg-green-50 border border-green-200 rounded-xl flex items-start space-x-3">
              <CheckCircle className="w-5 h-5 text-green-600 mt-0.5 flex-shrink-0" />
              <div className="flex-1">
                <p className="text-green-800 font-medium">Thành công!</p>
                <p className="text-green-700 text-sm mt-1">{successMessage}</p>
              </div>
            </div>
          )}

          {/* Error Message */}
          {serverError && (
            <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-xl flex items-start space-x-3">
              <XCircle className="w-5 h-5 text-red-600 mt-0.5 flex-shrink-0" />
              <div className="flex-1">
                <p className="text-red-800 font-medium">Lỗi!</p>
                <p className="text-red-700 text-sm mt-1">{serverError}</p>
              </div>
            </div>
          )}

          <form onSubmit={handleSubmit(onSubmit)} className="space-y-6">
            {/* Email Field */}
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-ink-700 mb-2">
                Email
              </label>
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-ink-400" />
                <input
                  id="email"
                  type="email"
                  {...register('email', {
                    required: 'Email không được để trống',
                    pattern: {
                      value: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i,
                      message: 'Email phải có định dạng hợp lệ'
                    }
                  })}
                  className={`input pl-10 ${errors.email ? 'border-red-500 focus:border-red-500 focus:ring-red-200' : ''}`}
                  placeholder="example@email.com"
                />
              </div>
              {errors.email && (
                <p className="mt-1 text-sm text-red-600">{errors.email.message}</p>
              )}
            </div>

            {/* Name Field */}
            <div>
              <label htmlFor="name" className="block text-sm font-medium text-ink-700 mb-2">
                Họ và tên
              </label>
              <div className="relative">
                <User className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-ink-400" />
                <input
                  id="name"
                  type="text"
                  {...register('name', {
                    required: 'Tên không được để trống',
                    maxLength: {
                      value: 50,
                      message: 'Tên không được vượt quá 50 ký tự'
                    }
                  })}
                  className={`input pl-10 ${errors.name ? 'border-red-500 focus:border-red-500 focus:ring-red-200' : ''}`}
                  placeholder="Nguyễn Văn A"
                />
              </div>
              {errors.name && (
                <p className="mt-1 text-sm text-red-600">{errors.name.message}</p>
              )}
            </div>

            {/* Password Field */}
            <div>
              <label htmlFor="password" className="block text-sm font-medium text-ink-700 mb-2">
                Mật khẩu
              </label>
              <div className="relative">
                <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-ink-400" />
                <input
                  id="password"
                  type="password"
                  {...register('password', {
                    required: 'Mật khẩu không được để trống',
                    minLength: {
                      value: 8,
                      message: 'Mật khẩu phải có ít nhất 8 ký tự'
                    },
                    maxLength: {
                      value: 16,
                      message: 'Mật khẩu không được vượt quá 16 ký tự'
                    }
                  })}
                  className={`input pl-10 ${errors.password ? 'border-red-500 focus:border-red-500 focus:ring-red-200' : ''}`}
                  placeholder="••••••••"
                />
              </div>
              {errors.password && (
                <p className="mt-1 text-sm text-red-600">{errors.password.message}</p>
              )}
            </div>

            {/* Confirm Password Field */}
            <div>
              <label htmlFor="confirmPassword" className="block text-sm font-medium text-ink-700 mb-2">
                Xác nhận mật khẩu
              </label>
              <div className="relative">
                <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-ink-400" />
                <input
                  id="confirmPassword"
                  type="password"
                  {...register('confirmPassword', {
                    required: 'Mật khẩu xác nhận không được để trống',
                    validate: (value) =>
                      value === password || 'Mật khẩu xác nhận phải trùng với mật khẩu'
                  })}
                  className={`input pl-10 ${errors.confirmPassword ? 'border-red-500 focus:border-red-500 focus:ring-red-200' : ''}`}
                  placeholder="••••••••"
                />
              </div>
              {errors.confirmPassword && (
                <p className="mt-1 text-sm text-red-600">{errors.confirmPassword.message}</p>
              )}
            </div>

            {/* Submit Button */}
            <button
              type="submit"
              disabled={isLoading}
              className="w-full btn-primary py-3 disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {isLoading ? (
                <span className="flex items-center justify-center">
                  <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Đang xử lý...
                </span>
              ) : (
                'Đăng ký'
              )}
            </button>
          </form>

          {/* Login Link */}
          <div className="mt-6 text-center">
            <p className="text-ink-600">
              Đã có tài khoản?{' '}
              <Link to="/login" className="text-wood-600 font-medium hover:text-wood-700 transition-colors">
                Đăng nhập ngay
              </Link>
            </p>
          </div>
        </div>

        {/* Back to Home */}
        <div className="mt-6 text-center">
          <Link to="/" className="text-ink-600 hover:text-ink-800 transition-colors text-sm">
            ← Quay lại trang chủ
          </Link>
        </div>
      </div>
    </div>
  );
}

export default Register;
