#!/bin/bash

set -euo pipefail

run_dir=$(cd ${0%/*}; pwd)
sidekiq="${run_dir}/sidekiq"
lib_dir="${run_dir}/../lib"
worker="${lib_dir}/mforwd/worker.rb"
threads=1

RUBYLIB=${RUBYLIB:-}
if [ "${RUBYLIB}" = "" ]; then
  export RUBYLIB=${lib_dir}
else
  RUBYLIB=${lib_dir}:${RUBYLIB}
fi

exec bundle exec ${sidekiq} -c ${threads} -r ${worker}

# Never comes here
exit 1

: <<'__EOF__'

=encoding utf8

=head1 NAME

B<mforwd-worker.sh> - sidekiq launcher for mforwd

=head1 SYNOPSYS

    mforwd-worker.sh

=head1 DESCRIPTION

This script launches sidekiq worker.

=head1 AUTHORS

YASUTAKE Kiyoshi E<lt>yasutake.kiyoshi@gmail.comE<gt>

=cut

__EOF__
