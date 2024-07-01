/*
* Iterator class to iterate over the csv data.
*
* Revision History:
*
* Version     Author           Date         Description
* 1.0                        10/07/2016    Initial Draft
*/
global with sharing class CSVIteratorClass implements Iterator<String>, Iterable<String> {
    private String m_CSVData;
    private String m_introValue;

    public CSVIteratorClass(String fileData, String introValue) {
        m_CSVData = fileData;
        m_introValue = introValue;
    }

    global Boolean hasNext() {
        return m_CSVData.length() > 1 ? true : false;
    }

    global String next() {
        String row = m_CSVData.subString(0, m_CSVData.indexOf(m_introValue));
        m_CSVData = m_CSVData.subString(m_CSVData.indexOf(m_introValue) + m_introValue.length(), m_CSVData.length());
        return row;
    }

    global Iterator<String> Iterator() {
        return this;
    }
}