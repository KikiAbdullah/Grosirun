import defaultTheme from 'tailwindcss/defaultTheme';
/** @type {import('tailwindcss').Config} */
export default {
    content: [
        './vendor/laravel/framework/src/Illuminate/Pagination/resources/views/*.blade.php',
        './storage/framework/views/*.php',
        './resources/views/**/*.blade.php',
    ],
    theme: {
        extend: {
            colors: {
                primary: { 50:'#F0FDF4',100:'#DCFCE7',200:'#BBF7D0',300:'#86EFAC',400:'#4ADE80',500:'#16A34A',600:'#15803D',700:'#166534',800:'#14532D',900:'#052E16' },
                danger:  { 50:'#FEF2F2',100:'#FEE2E2',500:'#EF4444',600:'#DC2626',700:'#B91C1C' },
                warning: { 50:'#FEFCE8',100:'#FEF9C3',500:'#FACC15',600:'#EAB308' },
                info:    { 50:'#EFF6FF',100:'#DBEAFE',500:'#3B82F6',600:'#2563EB' },
                surface: { 50:'#F8FAFC',100:'#F1F5F9',200:'#E2E8F0' },
                text:    { primary:'#0F172A', secondary:'#64748B', disabled:'#94A3B8' },
                offline: { bg:'#FEF9C3', text:'#854D0E' },
            },
            fontFamily: { sans: ['Inter', ...defaultTheme.fontFamily.sans] },
            fontSize: {
                'headline-lg': ['1.5rem',  { lineHeight:'2rem',   fontWeight:'800' }],
                'headline-md': ['1.25rem', { lineHeight:'1.75rem',fontWeight:'700' }],
                'title-lg':    ['1.125rem',{ lineHeight:'1.5rem', fontWeight:'600' }],
                'title-md':    ['1rem',    { lineHeight:'1.5rem', fontWeight:'600' }],
                'body-lg':     ['1rem',    { lineHeight:'1.5rem', fontWeight:'400' }],
                'body-md':     ['0.875rem',{ lineHeight:'1.5rem', fontWeight:'400' }],
                'body-sm':     ['0.75rem', { lineHeight:'1.5rem', fontWeight:'400' }],
                'label-lg':    ['1rem',    { lineHeight:'1.5rem', fontWeight:'600' }],
                'label-md':    ['0.875rem',{ lineHeight:'1.5rem', fontWeight:'600' }],
            },
            borderRadius: { 'xl':'0.875rem', '2xl':'1rem', '3xl':'1.5rem' },
            minHeight: { 'button':'3.5rem', 'touch':'3rem' },
            boxShadow: {
                'card':      '0 1px 3px 0 rgb(0 0 0/.04), 0 1px 2px -1px rgb(0 0 0/.04)',
                'card-hover':'0 4px 6px -1px rgb(0 0 0/.07), 0 2px 4px -2px rgb(0 0 0/.05)',
            },
            animation: {
                'skeleton': 'skeleton 1.5s ease-in-out infinite',
                'fade-in':  'fadeIn .2s ease-out',
                'slide-up': 'slideUp .3s ease-out',
            },
            keyframes: {
                skeleton: { '0%,100%':{opacity:'.5'}, '50%':{opacity:'1'} },
                fadeIn:   { '0%':{opacity:'0'}, '100%':{opacity:'1'} },
                slideUp:  { '0%':{transform:'translateY(10px)',opacity:'0'}, '100%':{transform:'translateY(0)',opacity:'1'} },
            },
        },
    },
    plugins: [],
};
