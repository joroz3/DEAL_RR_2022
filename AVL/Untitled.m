[token, remain] = strtok(str,'class = "gsc_a_at">')
[token, remain] = strtok(str,'class = "gsc_a_at">')
[token, remain] = strtok(remain, '<')
name = token
[token, remain] = strtok(remain,'class = "gsc_a_at">')
[token, remain] = strtok(remain, '<')
name1 = remain
[token, remain] = strtok(remain,'class = "gs_gray">')
[token, remain] = strtok(remain, '<')
author = remain
[token, remain] = strtok(remain,'class = "gs_gray">')
[token, remain] = strtok(remain, '<')
year1 = remain
[token, remain] = strtok(remain,'class = "gs_oph">')
[token, remain] = strtok(remain, '<')
Journal = remain
