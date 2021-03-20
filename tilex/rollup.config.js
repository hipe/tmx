import resolve from '@rollup/plugin-node-resolve';

export default {
  input: 'src/main.js',
  output: {
    file: 'public/bundles/d3.js',
    name: 'd3',
    format: 'iife',
    globals: {
      'd3-selection': 'd3Selection',
    },
  },
  plugins: [
    resolve(),  // locate modules using the node resolution algorithm
  ]
};
/*
# #born
*/
