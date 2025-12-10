import Joi from 'joi';

export const registerSchema = Joi.object({
  email: Joi.string()
    .email()
    .required()
    .messages({
      'string.email': 'Email phải có định dạng hợp lệ',
      'any.required': 'Email không được để trống'
    }),

  name: Joi.string()
    .max(50)
    .required()
    .messages({
      'string.max': 'Tên không được vượt quá 50 ký tự',
      'any.required': 'Tên không được để trống'
    }),

  password: Joi.string()
    .min(8)
    .max(16)
    .required()
    .messages({
      'string.min': 'Mật khẩu phải có ít nhất 8 ký tự',
      'string.max': 'Mật khẩu không được vượt quá 16 ký tự',
      'any.required': 'Mật khẩu không được để trống'
    }),

  confirmPassword: Joi.string()
    .valid(Joi.ref('password'))
    .required()
    .messages({
      'any.only': 'Mật khẩu xác nhận phải trùng với mật khẩu',
      'any.required': 'Mật khẩu xác nhận không được để trống'
    })
});

export const loginSchema = Joi.object({
  email: Joi.string()
    .email()
    .required()
    .messages({
      'string.email': 'Email phải có định dạng hợp lệ',
      'any.required': 'Email không được để trống'
    }),

  password: Joi.string()
    .min(8)
    .max(16)
    .required()
    .messages({
      'string.min': 'Mật khẩu phải có ít nhất 8 ký tự',
      'string.max': 'Mật khẩu không được vượt quá 16 ký tự',
      'any.required': 'Mật khẩu không được để trống'
    })
});
