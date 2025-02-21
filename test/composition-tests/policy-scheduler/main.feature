# Copyright 2023 Swisscom (Schweiz) AG

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

@PolicyScheduler
Feature: Policy scheduler composition
  Tests the policy scheduler composition

  Background:
    Given input claim xr.yaml
    And input composition composition.yaml
    And input functions functions.yaml
    Then check that no resources are provisioning

  @normal
  Scenario: Policy is assigned only within the scheduled time
    
    # render 1: Before schedule window
    When crossplane renders the composition at "2022-12-31T00:00:00Z"
    Then check that no resources are provisioning

    # render 2: During schedule window
    When crossplane renders the composition at "2023-02-01T00:00:00Z"
    Then check that 4 resources are provisioning and they are
      | role-app-1        |
      | role-app-2        |
      | role-app-1-policy |
      | role-app-2-policy |
    And check that resource role-app-1-policy has parameters
      | param name                | param value |
      | spec.forProvider.roleName | role-app-1  |
    And check that resource role-app-2-policy has parameters
      | param name                | param value |
      | spec.forProvider.roleName | role-app-2  |

    # render 3: After schedule window
    When crossplane renders the composition at "2024-01-01T00:00:00Z"
    Then check that no resources are provisioning
