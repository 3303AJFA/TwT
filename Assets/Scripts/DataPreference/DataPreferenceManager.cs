using System.Collections.Generic;
using UnityEngine;
using System.Linq;
using UnityEngine.SceneManagement;

public class DataPreferenceManager : MonoBehaviour
{
    [Header("File Storage Config")] 
    [SerializeField] private string fileName;

    private PreferenceData preferenceData;

    private List<IPrefDataPersistence> dataPreferenceObjects;
    private FilePreferenceDataHandler dataPreferenceHandler;
    
    public static DataPreferenceManager instance { get; private set; }
    

    private void Awake()
    {
        if (instance != null)
        {
            Debug.Log("Found more than one Data Persistence Manager in the scene. Destroying the newest one.");
            Destroy(this.gameObject);
            return;
        }

        instance = this;
        DontDestroyOnLoad(this.gameObject);
        
        this.dataPreferenceHandler = new FilePreferenceDataHandler(Application.persistentDataPath, fileName);
    }

    private void OnEnable()
    {
        SceneManager.sceneLoaded += OnSceneLoaded;
    }
    
    public void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        this.dataPreferenceObjects = FindAllPreferenceDataPersistenceObjects();
        LoadGame();
    }
    
    private void OnDisable()
    {
        SceneManager.sceneLoaded -= OnSceneLoaded;
    }

    public void NewGame()
    {
        this.preferenceData = new PreferenceData();
        SaveGame();
    }

    public void SaveGame()
    {
        if (this.preferenceData == null)
        {
            Debug.LogWarning("No data was found. A New Game needs to be started before data van saved.");
            NewGame();
            return;
        }
        
        foreach (IPrefDataPersistence dataPreferencePersistenceObj in dataPreferenceObjects)
        {
            dataPreferencePersistenceObj.SaveData(preferenceData);
        }
        
        dataPreferenceHandler.Save(preferenceData);
    }

    public void LoadGame()
    {
        this.preferenceData = dataPreferenceHandler.Load();

        if (this.preferenceData == null)
        {
            Debug.Log("No data was found. A New Game needs to be started before data can be loaded.");
            return;
        }

        foreach (IPrefDataPersistence dataPreferencePersistenceObj in dataPreferenceObjects)
        {
            dataPreferencePersistenceObj.LoadData(preferenceData);
        }
    }

    private void OnApplicationQuit()
    {
        SaveGame();
    }

    private List<IPrefDataPersistence> FindAllPreferenceDataPersistenceObjects()
    {
        IEnumerable<IPrefDataPersistence> dataPrefPersistenceObjects =
            FindObjectsOfType<MonoBehaviour>(true).OfType<IPrefDataPersistence>();
        return new List<IPrefDataPersistence>(dataPrefPersistenceObjects);
    }

    public bool HasPreferenceData()
    {
        return preferenceData != null;
    } 
}
