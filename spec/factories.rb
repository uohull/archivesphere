# Copyright © 2013 The Pennsylvania State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FactoryGirl.define do
  factory :user, :class => User do |u|
    sequence(:login) {|n| "user#{n}" }

    factory :approved_user do
      after(:build) { |u, evaluator| u.email = "#{u.login}@psu.edu"; u.stub(:groups).and_return(['umg/up.dlt.archivesphere-admin-viewers']) }
    end
  end

  factory :generic_file do 
    ignore do
      user nil
    end
    after(:build) { |gf, evaluator| gf.apply_depositor_metadata(evaluator.user) }
  end

  factory :accession do 
    ignore do
      user nil
    end
    after(:build) { |a, evaluator| a.apply_depositor_metadata(evaluator.user) }
  end


  factory :collection do
    ignore do
      user nil
    end
    after(:build) { |c, evaluator| c.apply_depositor_metadata(evaluator.user) }
  end
end

