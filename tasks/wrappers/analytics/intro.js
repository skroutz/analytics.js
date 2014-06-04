(function(global){
  // Set global to always reference the outer context's window
  // Applicable when the script runs inside a FIF
  if(global.inDapIF){
    global = global.top;
  }

  global._saq = global._saq || []
