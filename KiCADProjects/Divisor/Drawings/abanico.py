import numpy as np
import Draft

def makeLine(points):
    pl = FreeCAD.Placement()
    pl.Rotation.Q = (0.0,0.0,0.0,1.0)
    pl.Base = points[0]
    line = Draft.makeWire(points,placement=pl,closed=True,face=False,support=None)
    Draft.autogroup(line)

def makeCircle(center,radius):
    pl=FreeCAD.Placement()
    pl.Rotation.Q=(0.0,0.0,0.0,1.0)
    pl.Base=center
    circle = Draft.makeCircle(radius=radius,placement=pl,face=False,support=None)
    Draft.autogroup(circle)

boardRadius = 47 #mm
separationAngle = np.deg2rad(18.2) #degrees
resRadius = 20 #mm
resW = 1.9 #mm
resH = 3.7 #mm
mountRadius = 38 #mm
mountDiam = 3.2 #mm

#angle for input
inputAngle = 2*np.pi-15*separationAngle

#connector length
connLength = 2*boardRadius*np.tan(separationAngle/2)

#draw input
#track
trackPoints = [FreeCAD.Vector(0,0,0),FreeCAD.Vector(boardRadius,0,0)]
makeLine(trackPoints)
#connector
connPoints = [FreeCAD.Vector(boardRadius,-connLength/2,0),FreeCAD.Vector(boardRadius,connLength/2,0)]
makeLine(connPoints)
#resistor
xr1 = resRadius + resH/2
xr2 = resRadius - resH/2
yr1 = resW/2
yr2 = -resW/2
resPoints = [FreeCAD.Vector(xr1,yr1,0),FreeCAD.Vector(xr2,yr1,0),FreeCAD.Vector(xr2,yr2,0),FreeCAD.Vector(xr1,yr2,0)]
makeLine(resPoints)

#draw outputs
for i in range(0,16):
    #angle
    angle = inputAngle/2 + i*separationAngle
    #track
    trackPoints = [FreeCAD.Vector(0,0,0),FreeCAD.Vector(boardRadius*np.cos(angle),boardRadius*np.sin(angle),0)]
    makeLine(trackPoints)
    #connector
    connPoints = trackPoints
    connPoints[0] = trackPoints[1].add(FreeCAD.Vector(-0.5*connLength*np.cos(angle+0.5*np.pi),-0.5*connLength*np.sin(angle+0.5*np.pi),0))
    connPoints[1] = trackPoints[1].add(FreeCAD.Vector(0.5*connLength*np.cos(angle+0.5*np.pi),0.5*connLength*np.sin(angle+0.5*np.pi),0))
    makeLine(connPoints)
    #resistor
    pCen = FreeCAD.Vector(resRadius*np.cos(angle),resRadius*np.sin(angle),0)
    p1 = pCen.add(FreeCAD.Vector(0.5*resH*np.cos(angle),0.5*resH*np.sin(angle),0))
    p1 = p1.add(FreeCAD.Vector(0.5*resW*np.cos(angle+0.5*np.pi),0.5*resW*np.sin(angle+0.5*np.pi),0))
    p2 = p1.add(FreeCAD.Vector(-resH*np.cos(angle),-resH*np.sin(angle),0))
    p3 = p2.add(FreeCAD.Vector(-resW*np.cos(angle + 0.5*np.pi),-resW*np.sin(angle + 0.5*np.pi),0))
    p4 = p3.add(FreeCAD.Vector(resH*np.cos(angle),resH*np.sin(angle),0))
    resPoints = [p1,p2,p3,p4]
    makeLine(resPoints)

    if(i == 15):
        continue
    #mounting hole
    angle = angle + 0.5*separationAngle
    center = FreeCAD.Vector(mountRadius*np.cos(angle),mountRadius*np.sin(angle),0)
    makeCircle(center,0.5*mountDiam)

#input side mounting holes
angle = 0.25*inputAngle
center = FreeCAD.Vector(mountRadius*np.cos(angle),mountRadius*np.sin(angle),0)
makeCircle(center,0.5*mountDiam)
center = FreeCAD.Vector(mountRadius*np.cos(angle),-mountRadius*np.sin(angle),0)
makeCircle(center,0.5*mountDiam)

print("Done!")