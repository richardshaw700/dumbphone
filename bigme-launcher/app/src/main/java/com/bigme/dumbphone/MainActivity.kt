package com.bigme.dumbphone

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView

class MainActivity : AppCompatActivity() {

    private lateinit var adapter: AppAdapter

    // Apps structure - some are groups with children
    private val appStructure = listOf(
        AppItem("Phone", listOf(
            "com.google.android.dialer",
            "com.android.dialer",
            "com.samsung.android.dialer"
        )),
        AppGroup("Messages", listOf(
            AppItem("Unencrypted", listOf(
                "com.google.android.apps.messaging",
                "com.android.messaging"
            )),
            AppItem("Semi-encrypted", listOf("com.whatsapp")),
            AppItem("Encrypted", listOf("org.thoughtcrime.securesms"))
        )),
        AppItem("AI Chat", listOf("com.openai.chatgpt")),
        AppItem("Wallet", listOf("com.google.android.apps.walletnfcrel")),
        AppItem("Maps", listOf("com.google.android.apps.maps")),
        AppItem("Settings", listOf("com.android.settings")),
        AppItem("Weather", listOf("com.thewizrd.simpleweather")),
        AppItem("Calculator", listOf(
            "com.google.android.calculator",
            "com.android.calculator2"
        )),
        AppItem("Camera", listOf(
            "com.mediatek.camera",
            "com.android.camera2",
            "com.android.camera"
        )),
        AppItem("Photos", listOf("org.fossify.gallery")),
        AppItem("Email", listOf("com.readdle.spark")),
        AppItem("Doc Scanner", listOf("com.adobe.scan.android")),
        AppItem("AI Note Taker", listOf("com.aisense.otter")),
        AppItem("TD Bank", listOf("com.td")),
        AppItem("Scotiabank", listOf("com.scotiabank.banking")),
        AppItem("Smart Devices", listOf("com.tplink.kasa_android")),
        AppItem("Contacts", listOf(
            "com.google.android.contacts",
            "com.android.contacts"
        )),
        AppItem("Thermostat", listOf("com.ecobee.athenamobile")),
        AppItem("Quo", listOf("com.openphone"))
    )

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val recyclerView = findViewById<RecyclerView>(R.id.appList)
        recyclerView.layoutManager = LinearLayoutManager(this)
        
        adapter = AppAdapter(
            buildDisplayList(),
            onItemClick = { item -> launchApp(item) },
            onGroupClick = { group -> toggleGroup(group) }
        )
        recyclerView.adapter = adapter
    }

    private val expandedGroups = mutableSetOf<String>()

    private fun buildDisplayList(): List<DisplayItem> {
        val list = mutableListOf<DisplayItem>()
        for (item in appStructure) {
            when (item) {
                is AppItem -> list.add(DisplayItem.App(item, isChild = false))
                is AppGroup -> {
                    val isExpanded = expandedGroups.contains(item.name)
                    list.add(DisplayItem.Group(item, isExpanded))
                    if (isExpanded) {
                        for (child in item.children) {
                            list.add(DisplayItem.App(child, isChild = true))
                        }
                    }
                }
            }
        }
        return list
    }

    private fun toggleGroup(group: AppGroup) {
        if (expandedGroups.contains(group.name)) {
            expandedGroups.remove(group.name)
        } else {
            expandedGroups.add(group.name)
        }
        adapter.updateItems(buildDisplayList())
    }

    private fun launchApp(app: AppItem) {
        val pm = packageManager
        
        for (packageId in app.packageIds) {
            val intent = pm.getLaunchIntentForPackage(packageId)
            if (intent != null) {
                startActivity(intent)
                return
            }
        }
        
        Toast.makeText(
            this,
            "${app.displayName} not installed",
            Toast.LENGTH_SHORT
        ).show()
    }

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        // Do nothing - this is the home screen
    }
}

// Data classes
sealed class ListItem
data class AppItem(val displayName: String, val packageIds: List<String>) : ListItem()
data class AppGroup(val name: String, val children: List<AppItem>) : ListItem()

sealed class DisplayItem {
    data class App(val app: AppItem, val isChild: Boolean) : DisplayItem()
    data class Group(val group: AppGroup, val isExpanded: Boolean) : DisplayItem()
}

// Adapter
class AppAdapter(
    private var items: List<DisplayItem>,
    private val onItemClick: (AppItem) -> Unit,
    private val onGroupClick: (AppGroup) -> Unit
) : RecyclerView.Adapter<RecyclerView.ViewHolder>() {

    companion object {
        const val TYPE_APP = 0
        const val TYPE_GROUP = 1
    }

    fun updateItems(newItems: List<DisplayItem>) {
        items = newItems
        notifyDataSetChanged()
    }

    override fun getItemViewType(position: Int): Int {
        return when (items[position]) {
            is DisplayItem.App -> TYPE_APP
            is DisplayItem.Group -> TYPE_GROUP
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_app, parent, false)
        return AppViewHolder(view)
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val viewHolder = holder as AppViewHolder
        when (val item = items[position]) {
            is DisplayItem.App -> {
                val prefix = if (item.isChild) "      " else ""
                viewHolder.textView.text = "$prefix${item.app.displayName}"
                viewHolder.itemView.setOnClickListener { onItemClick(item.app) }
            }
            is DisplayItem.Group -> {
                viewHolder.textView.text = item.group.name
                viewHolder.itemView.setOnClickListener { onGroupClick(item.group) }
            }
        }
    }

    override fun getItemCount() = items.size

    class AppViewHolder(view: View) : RecyclerView.ViewHolder(view) {
        val textView: TextView = view.findViewById(R.id.appName)
    }
}
