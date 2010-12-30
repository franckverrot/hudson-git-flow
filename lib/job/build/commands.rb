module Commands
  class << self
    def build
      %{ 
      #!/bin/sh

      # Make sure we have all gems from only the test and dev groups.
      echo 'Running bundle install'
      bundle install --without production prelive legacy

      # Perform all migrations, also in the cucumber test database.
      echo 'Migrating the test and cucumber databases'
      rake db:migrate
      rake db:migrate RAILS_ENV=cucumber

      # Rspec tests.
      echo 'Running rake spec'
      rake spec
      retval=$?

      # Cucumber features using the default profile
      echo 'Running rake cucumber'
      rake cucumber
      retval=$(($?+$retval))

      # Blueridge javascript tests.
      echo 'Running rake spec:javascripts.'
      rake spec:javascripts
      retval=$(($?+$retval))

      exit $retval
      }
    end
  end

end