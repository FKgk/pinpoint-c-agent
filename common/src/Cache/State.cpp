////////////////////////////////////////////////////////////////////////////////
// Copyright 2024 NAVER Corp
//
// Licensed under the Apache License, Version 2.0 (the "License"); you may not
// use this file except in compliance with the License.  You may obtain a copy
// of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
// License for the specific language governing permissions and limitations under
// the License.
////////////////////////////////////////////////////////////////////////////////

#include "State.h"
#include "common.h"
#include "header.h"
#include <inttypes.h> /* For PRIu64 */

namespace PP {
ProcessState::ProcessState(int64_t trace_limit)
    : starttime_(get_unix_time_ms()), trace_limit_(trace_limit) {}

void ProcessState::SetStartTime(uint64_t start_time) {
  pp_trace("set start time:%lld", start_time);
  if (!ready_) {
    starttime_ = start_time;
    ready_ = true;
  }
}

bool ProcessState::CheckTraceLimit(int64_t timestamp) {
  std::time_t now = (timestamp != -1) ? (static_cast<std::time_t>(timestamp)) : (std::time(NULL));
  if (trace_limit_ == -1) {
    return false;
  } else if (trace_limit_ == 0) {
    goto LIMITED;
  }

  if (timestamp_ != now) {
    timestamp_ = now;
    tick_ = 0;
  } else if (tick_ >= trace_limit_) {
    goto LIMITED;
  }
  tick_++;
  return false;
LIMITED:
  pp_trace("This span dropped. max_trace_limit:%" PRIu64 " current_tick:%" PRIu64 " onLine:%d",
           trace_limit_, tick_.load(), (this->IsReady() ? (1) : (0)));
  return true;
}

} // namespace PP
