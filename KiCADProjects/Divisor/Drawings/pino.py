import numpy as np
import Draft

#initial params
s = 11.4 #mm
theta = np.deg2rad(15)
H = 100 #mm
wres = 1.9 #mm
hres = 3.7 #mm
dportres = 0.5 #fraction of d
dmount = 0.75 #fraction of d             
diamvia = 0.9 #mm
diammount = 3.2 #mm
posmount = [1,5]

#relevant magnitudes
hconn = s
W = 16*s
d = s/np.cos(theta)
l0 = H - (7+np.sin(theta)+0.5*np.cos(theta)**2)*d

#y-axis pointer
y = 0

#first line is l0
pl = FreeCAD.Placement()
pl.Rotation.Q = (0.0,0.0,0.0,1.0)
pl.Base = FreeCAD.Vector(0.0,y,0.0)
points = [FreeCAD.Vector(0.0,y,0.0),FreeCAD.Vector(0.0,l0,0.0)]
line = Draft.makeWire(points,placement=pl,closed=False,face=True,support=None)
Draft.autogroup(line)

#bottom connector
pl = FreeCAD.Placement()
pl.Rotation.Q = (0.0,0.0,0.0,1.0)
pl.Base = FreeCAD.Vector(0.0,y,0.0)
points = [FreeCAD.Vector(-0.5*hconn,y,0.0),FreeCAD.Vector(0.5*hconn,y,0.0)]
line = Draft.makeWire(points,placement=pl,closed=False,face=True,support=None)
Draft.autogroup(line)

#first resistor
xrescen = 0
yrescen = dportres*d
xr1 = xrescen - 0.5*wres
xr2 = xrescen + 0.5*wres
yr1 = yrescen - 0.5*hres
yr2 = yrescen + 0.5*hres
pl = FreeCAD.Placement()
pl.Rotation.Q = (0.0,0.0,0.0,1.0)
pl.Base = FreeCAD.Vector(xr1,yr1,0.0)
points = [FreeCAD.Vector(xr1,yr1,0.0),FreeCAD.Vector(xr1,yr2,0.0),FreeCAD.Vector(xr2,yr2,0.0),FreeCAD.Vector(xr2,yr1,0.0)]
line = Draft.makeWire(points,placement=pl,closed=True,face=False,support=None)
Draft.autogroup(line)

#advance in y-axis
y = y + l0

#draft the others
for i in range(0,8):
    #x,y for port
    xport = (8-i)*d*np.cos(theta)
    yport = y + (8-i)*d*np.sin(theta)

    #x,y for resistor center
    xrescen = xport - dportres*d*np.cos(theta)
    yrescen = yport - dportres*d*np.sin(theta)

    #x,y for resistor boundaries
    xr1 = xrescen - 0.5*hres*np.cos(theta) + 0.5*wres*np.cos(theta+0.5*np.pi)
    yr1 = yrescen - 0.5*hres*np.sin(theta) + 0.5*wres*np.sin(theta+0.5*np.pi)
    xr2 = xr1 + wres*np.cos(theta-0.5*np.pi)
    yr2 = yr1 + wres*np.sin(theta-0.5*np.pi)
    xr3 = xr2 + hres*np.cos(theta)
    yr3 = yr2 + hres*np.sin(theta)
    xr4 = xr3 + wres*np.cos(theta+0.5*np.pi)
    yr4 = yr3 + wres*np.sin(theta+0.5*np.pi)

    #x,y for via
    xvia = 0.5*(8-i)*d*np.cos(theta) + 0.5*s*np.cos(1.5*np.pi+theta)
    yvia = y + 0.5*(8-i)*d*np.sin(theta) + 0.5*s*np.sin(1.5*np.pi+theta)

    #x,y for conn
    xconnup = xport + 0.5*hconn*np.cos(theta+0.5*np.pi)
    yconnup = yport + 0.5*hconn*np.sin(theta+0.5*np.pi)
    xconndown = xport + 0.5*hconn*np.cos(theta-0.5*np.pi)
    yconndown = yport + 0.5*hconn*np.sin(theta-0.5*np.pi)

    #port lines
    pl = FreeCAD.Placement()
    pl.Rotation.Q = (0.0,0.0,0.0,1.0)
    pl.Base = FreeCAD.Vector(0.0,y,0.0)
    points = [FreeCAD.Vector(0.0,y,0.0),FreeCAD.Vector(xport,yport,0.0)]
    line = Draft.makeWire(points,placement=pl,closed=False,face=True,support=None)
    Draft.autogroup(line)

    pl = FreeCAD.Placement()
    pl.Rotation.Q = (0.0,0.0,0.0,1.0)
    pl.Base = FreeCAD.Vector(0.0,y,0.0)
    points = [FreeCAD.Vector(0.0,y,0.0),FreeCAD.Vector(-xport,yport,0.0)]
    line = Draft.makeWire(points,placement=pl,closed=False,face=True,support=None)
    Draft.autogroup(line)

    #resistors
    pl = FreeCAD.Placement()
    pl.Rotation.Q = (0.0,0.0,0.0,1.0)
    pl.Base = FreeCAD.Vector(xr1,yr1,0.0)
    points = [FreeCAD.Vector(xr1,yr1,0.0),FreeCAD.Vector(xr2,yr2,0.0),FreeCAD.Vector(xr3,yr3,0.0),FreeCAD.Vector(xr4,yr4,0.0)]
    line = Draft.makeWire(points,placement=pl,closed=True,face=False,support=None)
    Draft.autogroup(line)

    pl = FreeCAD.Placement()
    pl.Rotation.Q = (0.0,0.0,0.0,1.0)
    pl.Base = FreeCAD.Vector(-xr1,yr1,0.0)
    points = [FreeCAD.Vector(-xr1,yr1,0.0),FreeCAD.Vector(-xr2,yr2,0.0),FreeCAD.Vector(-xr3,yr3,0.0),FreeCAD.Vector(-xr4,yr4,0.0)]
    line = Draft.makeWire(points,placement=pl,closed=True,face=False,support=None)
    Draft.autogroup(line)

    #conn lines
    pl = FreeCAD.Placement()
    pl.Rotation.Q = (0.0,0.0,0.0,1.0)
    pl.Base = FreeCAD.Vector(xport,yport,0.0)
    points = [FreeCAD.Vector(xport,yport,0.0),FreeCAD.Vector(xconnup,yconnup,0.0)]
    line = Draft.makeWire(points,placement=pl,closed=True,face=False,support=None)
    Draft.autogroup(line)

    pl = FreeCAD.Placement()
    pl.Rotation.Q = (0.0,0.0,0.0,1.0)
    pl.Base = FreeCAD.Vector(-xport,yport,0.0)
    points = [FreeCAD.Vector(-xport,yport,0.0),FreeCAD.Vector(-xconnup,yconnup,0.0)]
    line = Draft.makeWire(points,placement=pl,closed=False,face=True,support=None)
    Draft.autogroup(line)

    pl = FreeCAD.Placement()
    pl.Rotation.Q = (0.0,0.0,0.0,1.0)
    pl.Base = FreeCAD.Vector(xport,yport,0.0)
    points = [FreeCAD.Vector(xport,yport,0.0),FreeCAD.Vector(xconndown,yconndown,0.0)]
    line = Draft.makeWire(points,placement=pl,closed=False,face=True,support=None)
    Draft.autogroup(line)

    pl = FreeCAD.Placement()
    pl.Rotation.Q = (0.0,0.0,0.0,1.0)
    pl.Base = FreeCAD.Vector(-xport,yport,0.0)
    points = [FreeCAD.Vector(-xport,yport,0.0),FreeCAD.Vector(-xconndown,yconndown,0.0)]
    line = Draft.makeWire(points,placement=pl,closed=False,face=True,support=None)
    Draft.autogroup(line)

    #vias
    pl=FreeCAD.Placement()
    pl.Rotation.Q=(0.0,0.0,0.0,1.0)
    pl.Base=FreeCAD.Vector(xvia,yvia,0.0)
    circle = Draft.makeCircle(radius=0.5*diamvia,placement=pl,face=False,support=None)
    Draft.autogroup(circle)

    pl=FreeCAD.Placement()
    pl.Rotation.Q=(0.0,0.0,0.0,1.0)
    pl.Base=FreeCAD.Vector(-xvia,yvia,0.0)
    circle = Draft.makeCircle(radius=0.5*diamvia,placement=pl,face=False,support=None)
    Draft.autogroup(circle)

    if(i == 7):
        continue

    #line to next section
    pl = FreeCAD.Placement()
    pl.Rotation.Q = (0.0,0.0,0.0,1.0)
    pl.Base = FreeCAD.Vector(0,y,0.0)
    points = [FreeCAD.Vector(0,y,0.0),FreeCAD.Vector(0,y+d,0.0)]
    line = Draft.makeWire(points,placement=pl,closed=False,face=True,support=None)
    Draft.autogroup(line)

    #advance in y
    y = y + d

#last via
xvia = 0
yvia = y + 0.5*(np.sin(theta)+0.5*np.cos(theta)**2)*d
pl=FreeCAD.Placement()
pl.Rotation.Q=(0.0,0.0,0.0,1.0)
pl.Base=FreeCAD.Vector(xvia,yvia,0.0)
circle = Draft.makeCircle(radius=0.5*diamvia,placement=pl,face=False,support=None)
Draft.autogroup(circle)

#mounting holes
for i in posmount:
    y = l0 + (i-1+0.5)*d

    xmount = 0.25*(8-i)*d*np.cos(theta)
    ymount = y + 0.25*(8-i)*d*np.sin(theta)

    #mounting holes
    pl=FreeCAD.Placement()
    pl.Rotation.Q=(0.0,0.0,0.0,1.0)
    pl.Base=FreeCAD.Vector(xmount,ymount,0.0)
    circle = Draft.makeCircle(radius=0.5*diammount,placement=pl,face=False,support=None)
    Draft.autogroup(circle)

    pl=FreeCAD.Placement()
    pl.Rotation.Q=(0.0,0.0,0.0,1.0)
    pl.Base=FreeCAD.Vector(-xmount,ymount,0.0)
    circle = Draft.makeCircle(radius=0.5*diammount,placement=pl,face=False,support=None)
    Draft.autogroup(circle)