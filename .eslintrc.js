module.exports = {
	env: {
		browser: true,
		es2021: true,
		node: true, // If you are using Node.js
	},
	extends: [
		'eslint:recommended',
		'plugin:@typescript-eslint/recommended',
		'plugin:react/recommended',
		'plugin:json/recommended',
	],
	parser: '@typescript-eslint/parser',
	parserOptions: {
		ecmaFeatures: {
			jsx: true,
		},
		ecmaVersion: 'latest',
		sourceType: 'module',
	},
	plugins: ['react', '@typescript-eslint', 'html', 'json'],
	rules: {
		semi: ['error', 'always'],
		quotes: ['error', 'single'],
		'no-unused-vars': 'warn',
		'react/prop-types': 'off',
	},
	settings: {
		react: {
			version: 'detect',
		},
	},
	overrides: [
		{
			files: ['**/*.css'],
			processor: 'stylelint-processor-styled-components',
		},
		{
			files: ['**/*.html'],
			processor: 'eslint-plugin-html',
		},
		{
			files: ['**/*.json'],
			processor: 'eslint-plugin-json',
		},
	],
};
