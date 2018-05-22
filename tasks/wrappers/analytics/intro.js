(function(global){
  // Set global to always reference the parent window context
  // Applicable when the script runs inside a FIF
  if(global.inDapIF){
    global = global.parent;
  }
