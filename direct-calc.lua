local RK = require 'Math.RungeKutta'
local G=9.8
local C=0.002
local sf=string.format
function dvdt(t,v)
		local a=G-C*v[1]*v[1] 
		return {a}
end 
--[[
-- calculate Y(t) than V(t)
function dydt(t,y)
		--calc v at t
		local v,t1,dt,k={0.0},0.0,0.1,0
		while t1<t do
				t1,dt,v=RK.rk4_auto(v,dvdt,t1,dt,0.00001)
				if not t1 then error(dt) end
				k=k+1
		end
		return v
end
function calc_y(t,y0)
		local y={y0}
		local t1=0
		local dt=0.1
		local k=0
		while t1<t do
				t1,dt,y=RK.rk4_auto(y,dydt,t1,dt,0.00001)
				if not t1 then 
						error(dt)
				end
				k=k+1
		end
		print('result:',t, y[1])
end
--]]
function calc_v(t,v0)
		local y={v0}
		local t1=0
		local dt=0.1
		local k=0
		while t1<t do
				local t2,y2
				t2,dt,y2=RK.rk4_auto(y,dvdt,t1,dt,0.00001)
				if not t2 then 
					error(dt)
				end
				k=k+1
				if t2==t then 
				   y=y2
				   t1=t
				   break
                                end
				if t2>t then 
				   -- interpolate the result
				   y={y[1]+(y2[1]-y[1])*(t-t1)/(t2-t1)}
				   t1=t
				   break
				end
				print(sf('%04d calc v(%.4f): %.4f',k,t2,y[1])) 
				t1=t2
				y=y2
		end
		return y[1],t1
end
local res,t=calc_v(120,0)
print(string.rep('=',80))
print('Vy('..t..')=',res)
