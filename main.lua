
local C=0.002
local G=9.8
local Y0=8000
local V0=800000

local consider_air=true

local Vec2_mt={}
Vec2_mt.__index=Vec2_mt

local function Vec2(x,y)
		return setmetatable({x or 0,y or 0},Vec2_mt)
end


function Vec2_mt:__add(v)
		local x,y
		if type(v)=='table' then
				x=self[1]+v[1]
				y=self[2]+v[2]
		elseif type(v)=='number' then
				x=self[1]+v
				y=self[2]+v
		else
				error('expect table or number')
		end
		return Vec2(x,y)
end

function Vec2_mt:__mul(v)
		local x,y
		if type(v)=='table' then
				x=self[1]*v[1]
				y=self[2]*v[2]
		elseif type(v)=='number' then
				x=self[1]*v
				y=self[2]*v
		else
				error('expect table or number')
		end
		return Vec2(x,y)

end

function Vec2_mt:__div(v)
		if type(v)=='table' then
				x=self[1]/v[1]
				y=self[2]/v[2]
		elseif type(v)=='number' then
				x=self[1]/v
				y=self[2]/v
		else
				error('expect table or number')
		end
		return Vec2(x,y)
end
function Vec2_mt:__sub(v)
		if type(v)=='table' then
				x=self[1]-v[1]
				y=self[2]-v[2]
		elseif type(v)=='number' then
				x=self[1]-v
				y=self[2]-v
		else
				error('expect table or number')
		end
		return Vec2(x,y)
end

function Vec2_mt:l2()
		return self[1]^2+self[2]^2
end

function Vec2_mt:dump()
		print(string.format('v:%f,%f',self[1],self[2]))
end

function Vec2_mt:dist()
		return math.sqrt(self:l2())
end

local function new_v(v,dt)
		local dvx=v:dist()*v[1]*C*dt
		local dvy=(G + C*v:dist()*v[2])*dt
		if dvx>v[1] then dvx=v[1] end
		if dvy<0 then dvy=0 end
		local v1=v - Vec2(dvx,dvy)
		return v1
end

local World={ x=0, y=1000,w=10000,h=10000} 
local lines={}
local Plane=function(p0,v0)
		local P={p=p0,v=v0,paused=true}
		function P:step(dt)
				if self.p[2]>=0 then
						self.p=self.v*dt+self.p
						if not consider_air then 
								self.v=self.v-Vec2(0,G*dt)
						else
								self.v=new_v(self.v,dt)
						end
						self.t1=love.timer.getTime()
						table.insert(lines,self.p[1])
						table.insert(lines,self.p[2])
				end
		end
		function P:reload()
				self.p=p0
				self.v=v0
				self.t0=love.timer.getTime()
				self.t1=nil
				lines={}
		end
		function P:draw()
				local x,y=love.graphics.transformPoint(self.p[1],self.p[2])	
				love.graphics.push()
				love.graphics.origin()
				love.graphics.setColor(1,0,0)		
				love.graphics.rectangle('fill',x-40,y-20,80,20)
				love.graphics.pop()
				if #lines>4 then 
						love.graphics.setColor(0,1,0)		
						love.graphics.line(lines)
				end
		end
		return P	
end


local plane
function love.load()
		love.window.setTitle('Simulation plane crash')
		plane=Plane(Vec2(100,Y0),Vec2(V0/(60*60),0))
end

function love.update(dt)
		if not plane.paused then 
				plane:step(dt)
		end
end

function love.draw()
		local w,h=love.graphics.getDimensions()

		love.graphics.push()
		love.graphics.scale(w/World.w,-h/World.h)
		love.graphics.translate(0,-(World.h-World.y))
		love.graphics.setColor(0.5,0.5,0.5)
		love.graphics.line(0,Y0,World.w,Y0)
		plane:draw()

		local _,y0=love.graphics.transformPoint(0,8000)	
		love.graphics.setColor(1,1,0)
		love.graphics.line(0,0,World.w,0)
		love.graphics.pop()

		love.graphics.setColor(0,1,1)
		local timing
		if plane.t1 then 
				timing=string.format('Took %d seconds',plane.t1 - plane.t0)
		else
				timing=''
		end
		local info=string.format('X=%d(m), Y=%d(m), Vx=%.1f(km/h), Vy=%.2f(m/s)',plane.p[1],plane.p[2],plane.v[1]*3600/1000,plane.v[2])
		local mode=consider_air and '[ Air ]' or '[ No air ]'
		love.graphics.print("Initial Height:"..Y0..'(m) '..mode,w-200,y0-16)
		love.graphics.setColor(1,0,0)
		love.graphics.print('Press ENTER to start or stop, SPACE to toggle air mode', 6 , y0-48)
		love.graphics.setColor(1,1,0)
		love.graphics.print("INFO: "..timing..', '..info,6,h-40)
end

function love.keypressed(key)
		print('got key:',key)
		if key=='return' then
				plane.paused=not plane.paused

				print(plane.paused and 'Puased' or 'Run')
				if plane.p[1]<=0 or not plane.paused then 
						plane:reload()
				end
		elseif key=='space' then 
				consider_air=not consider_air
		end
end
