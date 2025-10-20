package com.example.clinico

import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.os.Bundle
import android.view.View
import android.view.animation.OvershootInterpolator
import androidx.core.animation.doOnEnd
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        val splash = installSplashScreen()

        // أنيميشن الخروج (Android 12+)
        splash.setOnExitAnimationListener { splashScreenView ->
            val iconView = splashScreenView.iconView ?: return@setOnExitAnimationListener

            val scaleX = ObjectAnimator.ofFloat(iconView, View.SCALE_X, 1f, 0.88f, 1.06f, 1f)
            val scaleY = ObjectAnimator.ofFloat(iconView, View.SCALE_Y, 1f, 0.88f, 1.06f, 1f)
            val fade   = ObjectAnimator.ofFloat(iconView, View.ALPHA, 1f, 0.0f)

            AnimatorSet().apply {
                playTogether(scaleX, scaleY, fade)
                duration = 450
                interpolator = OvershootInterpolator()
                doOnEnd { splashScreenView.remove() } // لازم نشيله في الآخر
                start()
            }
        }

        super.onCreate(savedInstanceState)
    }
}
