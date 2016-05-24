process.env['PATH'] = process.env['PATH'] + ':' + process.env['LAMBDA_TASK_ROOT']

var exec = require('child_process').exec;
exports.handler = function(event, context) {
  var command = `./hello`;
  child = exec(command, {env: {'LD_LIBRARY_PATH': __dirname + '/lib'}}, function(error) {
    // Resolve with result of process
    context.done(error, 'Process complete!');
  });
  // Log process stdout and stderr
  child.stdout.on('data', console.log);
  child.stderr.on('data', console.error);
};
