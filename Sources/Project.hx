package;

import kha.Color;
import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.input.Mouse;
import kha.input.Keyboard;
import kha.Key;
import kha.Assets;

using kha.graphics2.GraphicsExtension;

class Project
{
	// radius of the circles to select the control points
	inline static var RADIUS:Int = 4;

	var fps:FramesPerSecond;
	var i:Int;

	// used to move a point
	var pointSelected:Int;
	
	// used to show the point that the mouse is over
	// with a different color
	var pointOver:Int;
	
	var showPoints:Bool;
	
	// list of points to construct the path
	var px:Array<Float> = [223, 300, 316, 312, 310, 347, 438, 532, 571, 594];
	var py:Array<Float> = [272, 185, 223, 303, 386, 380, 348, 312, 356, 402];

	public function new() 
	{		
		Assets.loadEverything(assetsLoaded);		
	}

	function assetsLoaded()
	{
		fps = new FramesPerSecond();
		pointSelected = -1;				
		pointOver = -1;
		showPoints = true;

		Mouse.get().notify(onMouseDown, onMouseUp, onMouseMove, null);
		Keyboard.get().notify(onKeyboardDown, null);
		
		System.notifyOnRender(render);
		Scheduler.addTimeTask(update, 0, 1 / 60);
	}	

	function update()
	{
		fps.update();
	}

	function onMouseDown(button:Int, x:Int, y:Int)
	{
		// iterate over the points and check if x/y position of the mouse
		// is inside a point. Uses a radius for better precision.
		// the point will be the point clicked because this is click event.
		for (i in 0...px.length)
		{
			if (x > px[i] - RADIUS && x < px[i] + RADIUS && y > py[i] - RADIUS && y < py[i] + RADIUS)
			{
				pointSelected = i;
				return;
			}
		}
	}

	function onMouseUp(button:Int, x:Int, y:Int)
	{
		// the mouse was released so we set to -1.
		// this represents no point selected.
		pointSelected = -1;
	}

	function onKeyboardDown(key:Key, char:String)
	{
		if (key == Key.TAB)
			showPoints = !showPoints;
	}

	function onMouseMove(x:Int, y:Int, movementX:Int, movementY:Int)
	{
		// if a point is selected, change its position
		if (pointSelected > -1)
		{
			px[pointSelected] = x;
			py[pointSelected] = y;
		}
		else
		{
			// if is not over a point selected, check if is over
			// the other points to draw in a different color
			for (i in 0...px.length)
			{
				if (x > px[i] - RADIUS && x < px[i] + RADIUS && y > py[i] - RADIUS && y < py[i] + RADIUS)
				{
					pointOver = i;
					return;
				}
			}
			
			// if the code reaches here it's because
			// the mouse isn't over any point
			pointOver = -1;
		}
	}			

	function render(fb:Framebuffer):Void 
	{		
		var g2 = fb.g2;
		g2.begin(true, Color.Black);		
		
		// render the path
		g2.color = Color.White;
		g2.drawCubicBezierPath(px, py, 100, 1);
			
		if (showPoints)
		{
			// render the guides
			i = 0;
			g2.color = Color.Blue;
			while (i < px.length)
			{
				if (i == 0)
					g2.drawLine(px[i], py[i], px[i + 1], py[i + 1], 2);
				else if (i == (px.length - 1))
					g2.drawLine(px[i], py[i], px[i - 1], py[i - 1], 2);
				else
				{
					g2.drawLine(px[i], py[i], px[i - 1], py[i - 1], 2);
					g2.drawLine(px[i], py[i], px[i + 1], py[i + 1], 2);
				}

				i += 3;
			}
			
			// render the point the mouse is over
			// with a different color
			for (i in 0...px.length)
			{
				if (pointSelected == i || pointOver == i)
					g2.color = Color.Green;
				else
					g2.color = Color.Orange;

				g2.fillCircle(px[i], py[i], 5);
			}
		}
		
		g2.end();
		
		// show the fps and some info
		g2.color = Color.White;
		g2.font = Assets.fonts.Vera;
		g2.fontSize = 25;
		g2.drawString('FPS: ${fps.fps}', 10, 10);
		g2.drawString('Press Tab to show/hide the points', 10, 35);

		fps.calcFrames();
	}
}