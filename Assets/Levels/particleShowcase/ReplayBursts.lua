-- Attach to a showcase group whose direct children are one-shot particle systems.
local ReplayBursts = {}
local cycleSeconds = 1.25

function ReplayBursts:OnActivate()
    self.children = nil
    self.index = 1
    self.remaining = 0
    self.tickHandler = TickBus.Connect(self)
end

function ReplayBursts:OnTick(deltaTime)
    self.remaining = self.remaining - deltaTime
    if self.remaining > 0 then
        return
    end

    -- Wait until the level's children have activated before reading the hierarchy.
    self.children = self.children or TransformBus.Event.GetChildren(self.entityId)
    local count = #self.children
    if count == 0 then
        self.children = nil
        self.remaining = cycleSeconds
        return
    end

    -- Play resumes the current clock. Stop first to start a fresh burst.
    local spacing = cycleSeconds / count
    local child = self.children[self.index]
    ParticleRequestBus.Event.Stop(child)
    ParticleRequestBus.Event.Play(child)
    self.index = self.index % count + 1
    -- On a slow frame, keep each burst visible and carry the rest to later ticks.
    self.remaining = math.max(0, self.remaining + spacing)
end

function ReplayBursts:OnDeactivate()
    self.tickHandler:Disconnect()
    self.tickHandler = nil
    self.children = nil
end

return ReplayBursts
